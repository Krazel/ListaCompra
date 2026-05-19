package com.dmkr.listacompra;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.GridLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Locale;
import java.util.UUID;

public class MainActivity extends Activity {
    private static final String PREFS = "lista_compra";
    private static final int REQUEST_PICK_IMAGE = 4101;

    private final ArrayList<Product> products = new ArrayList<>();
    private final ArrayList<ShoppingList> lists = new ArrayList<>();
    private final ArrayList<PresetList> presets = new ArrayList<>();
    private final ArrayList<Member> members = new ArrayList<>();

    private SharedPreferences prefs;
    private String activeListId = "";
    private int currentTab = 0;
    private boolean canEdit = true;
    private int quantity = 1;
    private EditText pendingImageInput;
    private String pendingImageUri = "";

    private final int background = Color.parseColor("#050806");
    private final int surface = Color.parseColor("#171B18");
    private final int surfaceSoft = Color.parseColor("#202720");
    private final int text = Color.parseColor("#F1F5F0");
    private final int muted = Color.parseColor("#9CA69D");
    private final int accent = Color.parseColor("#23C16B");
    private final int danger = Color.parseColor("#E34E49");

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        prefs = getSharedPreferences(PREFS, MODE_PRIVATE);
        load();
        render();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == REQUEST_PICK_IMAGE && resultCode == RESULT_OK && data != null && data.getData() != null) {
            Uri uri = data.getData();
            pendingImageUri = uri.toString();
            int flags = data.getFlags() & (Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
            try {
                getContentResolver().takePersistableUriPermission(uri, flags);
            } catch (Exception ignored) { }
            if (pendingImageInput != null) {
                pendingImageInput.setText(pendingImageUri);
            }
        }
    }

    private void render() {
        FrameLayout frame = new FrameLayout(this);
        frame.setBackgroundColor(background);

        ScrollView scroll = new ScrollView(this);
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setPadding(dp(20), dp(36), dp(20), dp(100));
        scroll.addView(root);
        frame.addView(scroll);

        if (currentTab == 0) showList(root);
        else if (currentTab == 1) showAdd(root);
        else if (currentTab == 2) showPresets(root);
        else showShare(root);

        frame.addView(bottomNav(), new FrameLayout.LayoutParams(-1, dp(74), Gravity.BOTTOM));
        setContentView(frame);
    }

    private void showList(LinearLayout root) {
        ShoppingList list = activeList();
        root.addView(compactListHeader(list));
        root.addView(listSwitcher());

        LinearLayout metrics = new LinearLayout(this);
        metrics.setOrientation(LinearLayout.HORIZONTAL);
        metrics.addView(metric("Total", String.valueOf(list.items.size())), new LinearLayout.LayoutParams(0, dp(58), 1));
        metrics.addView(withLeft(metric("Pendiente", String.valueOf(pendingCount())), 8), new LinearLayout.LayoutParams(0, dp(58), 1));
        metrics.addView(withLeft(metric("Hecho", String.valueOf(doneCount())), 8), new LinearLayout.LayoutParams(0, dp(58), 1));
        root.addView(withBottom(metrics, 10));
        root.addView(quickAddBar());

        root.addView(section("Por comprar"));
        int pending = 0;
        for (ShoppingItem item : list.items) {
            if (!item.checked) {
                root.addView(itemRow(item));
                pending++;
            }
        }
        if (pending == 0) root.addView(empty("No hay productos pendientes."));

        if (doneCount() > 0) {
            LinearLayout doneHeader = new LinearLayout(this);
            doneHeader.setGravity(Gravity.CENTER_VERTICAL);
            doneHeader.addView(section("Comprado"), new LinearLayout.LayoutParams(0, -2, 1));
            doneHeader.addView(textButton("Limpiar", v -> {
                list.items.removeIf(i -> i.checked);
                save();
                render();
            }), new LinearLayout.LayoutParams(dp(98), dp(42)));
            root.addView(doneHeader);
            for (ShoppingItem item : list.items) if (item.checked) root.addView(itemRow(item));
        }
    }

    private void showAdd(LinearLayout root) {
        root.addView(addHeader());
        root.addView(withBottom(actionButton("Buscar producto", v -> showSearchDialog()), 12), new LinearLayout.LayoutParams(-1, dp(44)));

        LinearLayout qty = card();
        LinearLayout row = new LinearLayout(this);
        row.setGravity(Gravity.CENTER_VERTICAL);
        row.addView(label("Cantidad", 15, text, true), new LinearLayout.LayoutParams(0, -2, 1));
        row.addView(textButton("-", v -> { quantity = Math.max(1, quantity - 1); render(); }), new LinearLayout.LayoutParams(dp(46), dp(40)));
        TextView value = label(String.valueOf(quantity), 18, text, true);
        value.setGravity(Gravity.CENTER);
        row.addView(value, new LinearLayout.LayoutParams(dp(46), dp(40)));
        row.addView(textButton("+", v -> { quantity++; render(); }), new LinearLayout.LayoutParams(dp(46), dp(40)));
        qty.addView(row);
        root.addView(withBottom(qty, 14));

        GridLayout grid = new GridLayout(this);
        grid.setColumnCount(2);
        for (Product product : products) {
            GridLayout.LayoutParams lp = new GridLayout.LayoutParams();
            lp.width = (getResources().getDisplayMetrics().widthPixels - dp(52)) / 2;
            lp.height = dp(158);
            lp.setMargins(0, 0, dp(12), dp(12));
            grid.addView(productCard(product), lp);
        }
        root.addView(grid);
    }

    private void showPresets(LinearLayout root) {
        root.addView(header("Listas predeterminadas", "Crea y usa listas para ahorrar tiempo."));
        LinearLayout create = card();
        create.addView(label("Crear con la lista actual", 18, text, true));
        create.addView(withTop(actionButton("Guardar predeterminada", v -> showCreatePresetDialog()), 12), new LinearLayout.LayoutParams(-1, dp(48)));
        root.addView(withBottom(create, 14));
        for (PresetList preset : presets) root.addView(presetCard(preset));
    }

    private void showShare(LinearLayout root) {
        root.addView(header("Compartir lista", "Gestiona miembros y envia la lista."));
        LinearLayout panel = card();
        LinearLayout top = new LinearLayout(this);
        top.setGravity(Gravity.CENTER_VERTICAL);
        top.addView(resourceIcon("app_group", 58));
        LinearLayout copy = new LinearLayout(this);
        copy.setOrientation(LinearLayout.VERTICAL);
        copy.setPadding(dp(12), 0, 0, 0);
        copy.addView(label(activeList().name, 18, text, true));
        copy.addView(label(members.size() + " personas", 13, muted, false));
        top.addView(copy, new LinearLayout.LayoutParams(0, -2, 1));
        top.addView(textButton("Enviar", v -> shareList()), new LinearLayout.LayoutParams(dp(96), dp(42)));
        panel.addView(top);
        TextView note = label("Ahora se comparte como texto. No hay sincronizacion en tiempo real todavia.", 13, muted, false);
        note.setPadding(0, dp(10), 0, 0);
        panel.addView(note);
        panel.addView(withTop(actionButton(canEdit ? "Permitir editar: si" : "Permitir editar: no", v -> {
            canEdit = !canEdit;
            save();
            render();
        }), 12), new LinearLayout.LayoutParams(-1, dp(48)));
        panel.addView(withTop(actionButton("Invitar", v -> showInviteDialog()), 10), new LinearLayout.LayoutParams(-1, dp(48)));
        root.addView(withBottom(panel, 14));

        for (Member member : members) root.addView(memberRow(member));

        LinearLayout preview = card();
        preview.addView(label("Vista previa", 18, text, true));
        TextView body = label(shareText(), 14, muted, false);
        body.setPadding(0, dp(10), 0, 0);
        preview.addView(body);
        root.addView(preview);
    }

    private View listSwitcher() {
        LinearLayout panel = new LinearLayout(this);
        panel.setOrientation(LinearLayout.HORIZONTAL);
        panel.setGravity(Gravity.CENTER_VERTICAL);
        LinearLayout row = new LinearLayout(this);
        row.setOrientation(LinearLayout.HORIZONTAL);
        for (ShoppingList list : lists) {
            Button chip = textButton(list.name, v -> {
                activeListId = list.id;
                save();
                render();
            });
            chip.setTextColor(list.id.equals(activeListId) ? text : accent);
            chip.setBackground(rounded(list.id.equals(activeListId) ? accent : withAlpha(accent, 32), 18));
            row.addView(withLeft(chip, row.getChildCount() == 0 ? 0 : 8), new LinearLayout.LayoutParams(-2, dp(36)));
        }
        panel.addView(row, new LinearLayout.LayoutParams(0, dp(38), 1));
        Button plus = textButton("+", v -> showCreateListDialog());
        plus.setTextSize(18);
        panel.addView(withLeft(plus, 8), new LinearLayout.LayoutParams(dp(40), dp(38)));
        return withBottom(panel, 10);
    }

    private void showMore(LinearLayout root) {
        root.addView(header("Mas", "Crea listas y cambia la lista activa."));
        LinearLayout create = card();
        create.addView(label("Nueva lista", 18, text, true));
        create.addView(withTop(actionButton("Crear lista", v -> showCreateListDialog()), 12), new LinearLayout.LayoutParams(-1, dp(48)));
        root.addView(withBottom(create, 14));

        for (ShoppingList list : lists) {
            LinearLayout row = new LinearLayout(this);
            row.setGravity(Gravity.CENTER_VERTICAL);
            row.setPadding(dp(12), dp(12), dp(12), dp(12));
            row.setBackground(rounded(surface, 8));
            TextView state = label(list.id.equals(activeListId) ? "OK" : "--", 13, list.id.equals(activeListId) ? accent : muted, true);
            state.setGravity(Gravity.CENTER);
            row.addView(state, new LinearLayout.LayoutParams(dp(42), dp(42)));
            LinearLayout textBox = new LinearLayout(this);
            textBox.setOrientation(LinearLayout.VERTICAL);
            textBox.addView(label(list.name, 17, text, true));
            textBox.addView(label(list.items.size() + " productos", 13, muted, false));
            row.addView(textBox, new LinearLayout.LayoutParams(0, -2, 1));
            row.addView(textButton("Usar", v -> { activeListId = list.id; save(); render(); }), new LinearLayout.LayoutParams(dp(72), dp(42)));
            row.addView(textButton("Borrar", v -> {
                if (lists.size() > 1) {
                    lists.remove(list);
                    if (activeListId.equals(list.id)) activeListId = lists.get(0).id;
                    save();
                    render();
                }
            }), new LinearLayout.LayoutParams(dp(82), dp(42)));
            root.addView(withBottom(row, 10));
        }
    }

    private View itemRow(ShoppingItem item) {
        LinearLayout row = new LinearLayout(this);
        row.setGravity(Gravity.CENTER_VERTICAL);
        row.setPadding(dp(12), dp(12), dp(12), dp(12));
        row.setBackground(rounded(surface, 8));

        row.addView(textButton(item.checked ? "OK" : "", v -> {
            item.checked = !item.checked;
            save();
            render();
        }), new LinearLayout.LayoutParams(dp(42), dp(42)));
        row.addView(productIcon(item.product, 46));

        LinearLayout textBox = new LinearLayout(this);
        textBox.setOrientation(LinearLayout.VERTICAL);
        textBox.setPadding(dp(10), 0, 0, 0);
        textBox.addView(label(item.product.name, 16, item.checked ? muted : text, true));
        textBox.addView(label(item.quantity + " " + item.product.unit, 13, muted, false));
        row.addView(textBox, new LinearLayout.LayoutParams(0, -2, 1));

        row.addView(textButton("-", v -> { item.quantity = Math.max(1, item.quantity - 1); save(); render(); }), new LinearLayout.LayoutParams(dp(36), dp(38)));
        row.addView(textButton("+", v -> { item.quantity++; save(); render(); }), new LinearLayout.LayoutParams(dp(36), dp(38)));
        row.addView(textButton("Borrar", v -> { activeList().items.remove(item); save(); render(); }), new LinearLayout.LayoutParams(dp(76), dp(38)));
        return withBottom(row, 10);
    }

    private View productCard(Product product) {
        LinearLayout card = new LinearLayout(this);
        card.setOrientation(LinearLayout.VERTICAL);
        card.setPadding(dp(14), dp(14), dp(14), dp(14));
        card.setBackground(rounded(surface, 8));
        card.setOnClickListener(v -> {
            addProduct(product, quantity);
            Toast.makeText(this, product.name + " anadido", Toast.LENGTH_SHORT).show();
            currentTab = 0;
            render();
        });
        card.addView(productIcon(product, 54));
        card.addView(withTop(label(product.name, 16, text, true), 10));
        card.addView(label(defaultDisplayUnit(product), 12, muted, true));
        TextView add = label("+ Anadir", 13, accent, true);
        add.setPadding(0, dp(10), 0, 0);
        card.addView(add);
        return card;
    }

    private String defaultDisplayUnit(Product product) {
        String key = product.name.toLowerCase(Locale.ROOT);
        if (key.equals("leche")) return "1 L";
        if (key.equals("huevos")) return "12 uds";
        if (key.equals("tomates")) return "500 g";
        if (key.equals("platanos") || key.equals("manzanas") || key.equals("arroz")) return "1 kg";
        if (key.equals("papel higienico")) return "6 uds";
        if (key.equals("pasta") || key.equals("cafe")) return "1 paq";
        if (key.equals("congelados")) return "1 bolsa";
        return "1 " + product.unit;
    }

    private View presetCard(PresetList preset) {
        LinearLayout card = card();
        LinearLayout row = new LinearLayout(this);
        row.setGravity(Gravity.CENTER_VERTICAL);
        row.addView(resourceIcon(preset.imageName, 66));
        LinearLayout copy = new LinearLayout(this);
        copy.setOrientation(LinearLayout.VERTICAL);
        copy.setPadding(dp(12), 0, 0, 0);
        copy.addView(label(preset.name, 19, text, true));
        copy.addView(label(preset.productNames.size() + " productos", 13, muted, false));
        row.addView(copy, new LinearLayout.LayoutParams(0, -2, 1));
        row.addView(textButton("Editar", v -> showEditPresetDialog(preset)), new LinearLayout.LayoutParams(dp(84), dp(42)));
        row.addView(textButton("Usar", v -> {
            for (String name : preset.productNames) {
                Product p = findProduct(name);
                if (p != null) addProduct(p, 1);
            }
            save();
            currentTab = 0;
            render();
        }), new LinearLayout.LayoutParams(dp(84), dp(42)));
        card.addView(row);
        LinearLayout icons = new LinearLayout(this);
        icons.setPadding(0, dp(12), 0, 0);
        for (String name : preset.productNames) {
            Product product = findProduct(name);
            if (product != null) icons.addView(productIcon(product, 34));
        }
        card.addView(icons);
        return withBottom(card, 12);
    }

    private void showEditPresetDialog(PresetList preset) {
        LinearLayout form = dialogForm();
        EditText name = input("Nombre");
        name.setText(preset.name);
        EditText productsInput = input("Productos separados por coma");
        productsInput.setText(String.join(", ", preset.productNames));
        form.addView(name);
        form.addView(productsInput);
        new AlertDialog.Builder(this)
            .setTitle("Editar lista base")
            .setView(form)
            .setNegativeButton("Borrar", (dialog, which) -> {
                presets.remove(preset);
                save();
                render();
            })
            .setNeutralButton("Cancelar", null)
            .setPositiveButton("Guardar", (dialog, which) -> {
                preset.name = blankTo(name.getText().toString(), preset.name);
                preset.productNames.clear();
                for (String part : productsInput.getText().toString().split("[,;\\n]")) {
                    String productName = part.trim();
                    if (productName.isEmpty()) continue;
                    preset.productNames.add(productName);
                    if (findProduct(productName) == null) {
                        products.add(new Product(productName, "Importados", "ud", Product.defaultImage(productName), ""));
                    }
                }
                save();
                render();
            })
            .show();
    }

    private View memberRow(Member member) {
        LinearLayout row = new LinearLayout(this);
        row.setGravity(Gravity.CENTER_VERTICAL);
        row.setPadding(dp(12), dp(12), dp(12), dp(12));
        row.setBackground(rounded(surface, 8));
        TextView avatar = label(initials(member.name), 14, Color.WHITE, true);
        avatar.setGravity(Gravity.CENTER);
        avatar.setBackground(rounded(accent, 8));
        row.addView(avatar, new LinearLayout.LayoutParams(dp(42), dp(42)));
        LinearLayout copy = new LinearLayout(this);
        copy.setOrientation(LinearLayout.VERTICAL);
        copy.setPadding(dp(12), 0, 0, 0);
        copy.addView(label(member.name, 16, text, true));
        copy.addView(label(member.permission, 13, muted, false));
        row.addView(copy, new LinearLayout.LayoutParams(0, -2, 1));
        row.addView(textButton("Borrar", v -> { members.remove(member); save(); render(); }), new LinearLayout.LayoutParams(dp(86), dp(42)));
        return withBottom(row, 10);
    }

    private View productIcon(Product product, int size) {
        if (!product.imageUri.trim().isEmpty()) {
            ImageView image = new ImageView(this);
            try {
                image.setImageURI(Uri.parse(product.imageUri));
            } catch (Exception ignored) {
                int resId = getResources().getIdentifier(product.imageName, "drawable", getPackageName());
                image.setImageResource(resId == 0 ? getResources().getIdentifier("product_default", "drawable", getPackageName()) : resId);
            }
            image.setScaleType(ImageView.ScaleType.CENTER_CROP);
            LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(dp(size), dp(size));
            lp.setMargins(0, 0, dp(6), 0);
            image.setLayoutParams(lp);
            return image;
        }
        if (!product.emoji.trim().isEmpty()) {
            TextView emoji = label(product.emoji.trim(), Math.max(18, size / 2), text, true);
            emoji.setGravity(Gravity.CENTER);
            emoji.setBackground(rounded(surfaceSoft, 8));
            LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(dp(size), dp(size));
            lp.setMargins(0, 0, dp(6), 0);
            emoji.setLayoutParams(lp);
            return emoji;
        }
        return resourceIcon(product.imageName, size);
    }

    private View resourceIcon(String imageName, int size) {
        ImageView image = new ImageView(this);
        int resId = getResources().getIdentifier(imageName, "drawable", getPackageName());
        if (resId == 0) resId = getResources().getIdentifier("product_default", "drawable", getPackageName());
        image.setImageResource(resId);
        image.setScaleType(ImageView.ScaleType.FIT_CENTER);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(dp(size), dp(size));
        lp.setMargins(0, 0, dp(6), 0);
        image.setLayoutParams(lp);
        return image;
    }

    private View header(String title, String subtitle) {
        LinearLayout box = new LinearLayout(this);
        box.setOrientation(LinearLayout.VERTICAL);
        box.setPadding(0, 0, 0, dp(16));
        box.addView(label(title, 30, text, true));
        box.addView(label(subtitle, 15, muted, false));
        return box;
    }

    private View compactListHeader(ShoppingList list) {
        LinearLayout row = new LinearLayout(this);
        row.setGravity(Gravity.CENTER_VERTICAL);
        row.setPadding(0, 0, 0, dp(12));
        LinearLayout copy = new LinearLayout(this);
        copy.setOrientation(LinearLayout.VERTICAL);
        copy.addView(label(list.name, 30, text, true));
        copy.addView(label("Lista de la compra", 14, muted, false));
        row.addView(copy, new LinearLayout.LayoutParams(0, -2, 1));
        Button menu = textButton("...", v -> showListMenu());
        menu.setTextSize(20);
        row.addView(menu, new LinearLayout.LayoutParams(dp(44), dp(42)));
        return row;
    }

    private View addHeader() {
        LinearLayout row = new LinearLayout(this);
        row.setGravity(Gravity.CENTER_VERTICAL);
        row.setPadding(0, 0, 0, dp(16));
        LinearLayout copy = new LinearLayout(this);
        copy.setOrientation(LinearLayout.VERTICAL);
        copy.addView(label("Anadir productos", 30, text, true));
        copy.addView(label("Catalogo con imagen o emoji por producto.", 14, muted, false));
        row.addView(copy, new LinearLayout.LayoutParams(0, -2, 1));
        Button plus = textButton("+", v -> showCreateProductDialog());
        plus.setTextSize(22);
        plus.setTextColor(text);
        plus.setBackground(rounded(accent, 8));
        row.addView(plus, new LinearLayout.LayoutParams(dp(44), dp(42)));
        return row;
    }

    private View quickAddBar() {
        LinearLayout row = new LinearLayout(this);
        row.setGravity(Gravity.CENTER_VERTICAL);
        row.setPadding(dp(10), dp(8), dp(10), dp(8));
        row.setBackground(rounded(surface, 8));
        EditText input = input("Anadir o buscar producto");
        row.addView(input, new LinearLayout.LayoutParams(0, dp(42), 1));
        row.addView(withLeft(textButton("Pegar", v -> showBulkImportDialog()), 8), new LinearLayout.LayoutParams(dp(76), dp(42)));
        row.addView(withLeft(textButton("+", v -> showCreateProductDialog()), 8), new LinearLayout.LayoutParams(dp(42), dp(42)));
        input.setOnEditorActionListener((v, actionId, event) -> {
            addByQuery(input.getText().toString());
            return true;
        });
        return withBottom(row, 12);
    }

    private void addByQuery(String value) {
        String query = value.trim().toLowerCase(Locale.ROOT);
        if (query.isEmpty()) return;
        for (Product product : products) {
            if (product.name.toLowerCase(Locale.ROOT).contains(query) || product.category.toLowerCase(Locale.ROOT).contains(query)) {
                addProduct(product, 1);
                render();
                return;
            }
        }
        showCreateProductDialog(query);
    }

    private void showListMenu() {
        String[] actions = lists.size() > 1
            ? new String[]{"Copiar lista", "Eliminar lista"}
            : new String[]{"Copiar lista"};
        new AlertDialog.Builder(this)
            .setTitle(activeList().name)
            .setItems(actions, (dialog, which) -> {
                if (which == 0) shareList();
                else {
                    ShoppingList current = activeList();
                    lists.remove(current);
                    activeListId = lists.get(0).id;
                    save();
                    render();
                }
            })
            .show();
    }

    private View bottomNav() {
        LinearLayout nav = new LinearLayout(this);
        nav.setGravity(Gravity.CENTER);
        nav.setPadding(dp(6), dp(6), dp(6), dp(6));
        nav.setBackgroundColor(surface);
        String[] labels = {"Lista", "Anadir", "Pred.", "Compartir"};
        for (int i = 0; i < labels.length; i++) {
            final int tab = i;
            TextView item = label(labels[i], 11, currentTab == tab ? accent : muted, true);
            item.setGravity(Gravity.CENTER);
            item.setOnClickListener(v -> { currentTab = tab; render(); });
            nav.addView(item, new LinearLayout.LayoutParams(0, -1, 1));
        }
        return nav;
    }

    private void showSearchDialog() {
        EditText input = input("Buscar producto");
        new AlertDialog.Builder(this)
            .setTitle("Buscar producto")
            .setView(input)
            .setNegativeButton("Cancelar", null)
            .setPositiveButton("Anadir", (dialog, which) -> {
                String query = input.getText().toString().trim().toLowerCase(Locale.ROOT);
                for (Product product : products) {
                    if (product.name.toLowerCase(Locale.ROOT).contains(query) || product.category.toLowerCase(Locale.ROOT).contains(query)) {
                        addProduct(product, quantity);
                        currentTab = 0;
                        render();
                        return;
                    }
                }
            })
            .show();
    }

    private void showCreateProductDialog() {
        showCreateProductDialog("");
    }

    private void showCreateProductDialog(String prefill) {
        pendingImageUri = "";
        pendingImageInput = null;
        LinearLayout form = dialogForm();
        EditText name = input("Nombre");
        name.setText(prefill);
        EditText category = input("Categoria");
        EditText unit = input("Unidad, ej. ud, kg, l");
        EditText emoji = input("Emoji o deja vacio");
        EditText image = input("Imagen de la app, ej. product_rice");
        EditText imageUri = input("Imagen del movil");
        imageUri.setFocusable(false);
        pendingImageInput = imageUri;
        form.addView(name);
        form.addView(category);
        form.addView(unit);
        form.addView(emoji);
        form.addView(image);
        form.addView(imageUri);
        form.addView(withTop(actionButton("Elegir imagen del movil", v -> pickImageFromMobile()), 10), new LinearLayout.LayoutParams(-1, dp(48)));
        new AlertDialog.Builder(this)
            .setTitle("Nuevo producto")
            .setView(form)
            .setNegativeButton("Cancelar", null)
            .setPositiveButton("Guardar", (dialog, which) -> {
                String cleaned = name.getText().toString().trim();
                if (!cleaned.isEmpty()) {
                    String safeUnit = unit.getText().toString().trim().isEmpty() ? "ud" : unit.getText().toString().trim();
                    String imageName = image.getText().toString().trim().isEmpty() ? Product.defaultImage(cleaned) : image.getText().toString().trim();
                    products.add(new Product(cleaned, blankTo(category.getText().toString(), "Otros"), safeUnit, imageName, emoji.getText().toString().trim(), imageUri.getText().toString().trim()));
                    save();
                    render();
                }
            })
            .show();
    }

    private void pickImageFromMobile() {
        Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType("image/*");
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION);
        startActivityForResult(intent, REQUEST_PICK_IMAGE);
    }

    private void showBulkImportDialog() {
        LinearLayout form = dialogForm();
        EditText input = new EditText(this);
        input.setHint("Patatas, palomitas, leche...");
        input.setMinLines(5);
        input.setGravity(Gravity.TOP);
        form.addView(input);
        new AlertDialog.Builder(this)
            .setTitle("Pegar lista rapida")
            .setMessage("Los productos que no existan se anadiran al catalogo con imagen automatica.")
            .setView(form)
            .setNegativeButton("Cancelar", null)
            .setPositiveButton("Anadir", (dialog, which) -> {
                String[] parts = input.getText().toString().split("[,;\\n]");
                for (String part : parts) {
                    String name = part.trim();
                    if (name.isEmpty()) continue;
                    Product product = findProduct(name);
                    if (product == null) {
                        product = new Product(name, "Importados", "ud", Product.defaultImage(name), "");
                        products.add(product);
                    }
                    addProduct(product, 1);
                }
                save();
                render();
            })
            .show();
    }

    private void showCreatePresetDialog() {
        EditText input = input("Nombre");
        new AlertDialog.Builder(this)
            .setTitle("Nueva predeterminada")
            .setView(input)
            .setNegativeButton("Cancelar", null)
            .setPositiveButton("Guardar", (dialog, which) -> {
                String name = input.getText().toString().trim();
                if (!name.isEmpty()) {
                    ArrayList<String> names = new ArrayList<>();
                    for (ShoppingItem item : activeList().items) names.add(item.product.name);
                    presets.add(new PresetList(name, "preset_weekly", names));
                    save();
                    render();
                }
            })
            .show();
    }

    private void showCreateListDialog() {
        EditText input = input("Nombre");
        new AlertDialog.Builder(this)
            .setTitle("Nueva lista")
            .setView(input)
            .setNegativeButton("Cancelar", null)
            .setPositiveButton("Crear", (dialog, which) -> {
                String name = input.getText().toString().trim();
                if (!name.isEmpty()) {
                    ShoppingList list = new ShoppingList(name);
                    lists.add(list);
                    activeListId = list.id;
                    save();
                    render();
                }
            })
            .show();
    }

    private void showInviteDialog() {
        EditText input = input("Nombre");
        new AlertDialog.Builder(this)
            .setTitle("Invitar")
            .setView(input)
            .setNegativeButton("Cancelar", null)
            .setPositiveButton("Anadir", (dialog, which) -> {
                String cleaned = input.getText().toString().trim();
                if (!cleaned.isEmpty()) {
                    members.add(new Member(cleaned, "Puede editar"));
                    save();
                    render();
                }
            })
            .show();
    }

    private void shareList() {
        Intent send = new Intent(Intent.ACTION_SEND);
        send.setType("text/plain");
        send.putExtra(Intent.EXTRA_TEXT, shareText());
        startActivity(Intent.createChooser(send, "Compartir lista"));
    }

    private void addProduct(Product product, int amount) {
        ShoppingList list = activeList();
        for (ShoppingItem item : list.items) {
            if (item.product.name.equals(product.name) && !item.checked) {
                item.quantity += Math.max(1, amount);
                save();
                return;
            }
        }
        list.items.add(0, new ShoppingItem(product, Math.max(1, amount), false));
        save();
    }

    private ShoppingList activeList() {
        for (ShoppingList list : lists) if (list.id.equals(activeListId)) return list;
        if (lists.isEmpty()) {
            ShoppingList list = new ShoppingList("Lista de la compra");
            lists.add(list);
            activeListId = list.id;
        }
        return lists.get(0);
    }

    private Product findProduct(String name) {
        for (Product product : products) if (product.name.equals(name)) return product;
        return null;
    }

    private int pendingCount() {
        int count = 0;
        for (ShoppingItem item : activeList().items) if (!item.checked) count++;
        return count;
    }

    private int doneCount() {
        int count = 0;
        for (ShoppingItem item : activeList().items) if (item.checked) count++;
        return count;
    }

    private String shareText() {
        StringBuilder builder = new StringBuilder(activeList().name).append("\n");
        for (ShoppingItem item : activeList().items) {
            builder.append("- ").append(item.product.name).append(": ").append(item.quantity).append(" ").append(item.product.unit);
            if (item.checked) builder.append(" (comprado)");
            builder.append("\n");
        }
        return builder.toString();
    }

    private void load() {
        loadProducts();
        loadLists();
        loadPresets();
        loadMembers();
        canEdit = prefs.getBoolean("canEdit", true);
    }

    private void loadProducts() {
        products.clear();
        String raw = prefs.getString("products.v2", "");
        if (!raw.isEmpty()) {
            try {
                JSONArray array = new JSONArray(raw);
                for (int i = 0; i < array.length(); i++) products.add(Product.from(array.getJSONObject(i)));
            } catch (Exception ignored) {
                products.clear();
            }
        }
        if (products.isEmpty()) {
            products.add(new Product("Leche", "Lacteos", "l", "product_milk", ""));
            products.add(new Product("Pan", "Panaderia", "ud", "product_bread", ""));
            products.add(new Product("Huevos", "Lacteos", "uds", "product_eggs", ""));
            products.add(new Product("Tomates", "Frescos", "g", "product_tomato", ""));
            products.add(new Product("Platanos", "Fruta", "kg", "product_banana", ""));
            products.add(new Product("Manzanas", "Fruta", "kg", "product_apple", ""));
            products.add(new Product("Detergente", "Limpieza", "ud", "product_detergent", ""));
            products.add(new Product("Papel higienico", "Limpieza", "uds", "product_paper", ""));
            products.add(new Product("Aceite de oliva", "Despensa", "ud", "product_oil", ""));
            products.add(new Product("Arroz", "Despensa", "kg", "product_rice", ""));
            products.add(new Product("Pasta", "Despensa", "paq", "product_pasta", ""));
            products.add(new Product("Cafe", "Desayuno", "paq", "product_coffee", ""));
            products.add(new Product("Congelados", "Congelador", "bol", "product_frozen", ""));
            products.add(new Product("Queso", "Lacteos", "ud", "product_cheese", ""));
            products.add(new Product("Agua", "Bebidas", "l", "product_water", ""));
        }
    }

    private void loadLists() {
        lists.clear();
        String raw = prefs.getString("lists.v2", "");
        if (!raw.isEmpty()) {
            try {
                JSONArray array = new JSONArray(raw);
                for (int i = 0; i < array.length(); i++) lists.add(ShoppingList.from(array.getJSONObject(i)));
            } catch (Exception ignored) {
                lists.clear();
            }
        }
        if (lists.isEmpty()) {
            ShoppingList list = new ShoppingList("Lista de la compra");
            for (String name : Arrays.asList("Leche", "Pan", "Huevos", "Tomates", "Platanos", "Detergente", "Papel higienico")) {
                Product product = findProduct(name);
                if (product != null) list.items.add(new ShoppingItem(product, name.equals("Tomates") ? 500 : 1, false));
            }
            lists.add(list);
        }
        if (lists.size() == 1 && "Lista de la compra".equals(lists.get(0).name)) {
            lists.add(new ShoppingList("Casa"));
            lists.add(new ShoppingList("Semana"));
            lists.add(new ShoppingList("Fiesta"));
        }
        activeListId = prefs.getString("activeListId.v2", lists.get(0).id);
    }

    private void loadPresets() {
        presets.clear();
        String raw = prefs.getString("presets.v2", "");
        if (!raw.isEmpty()) {
            try {
                JSONArray array = new JSONArray(raw);
                for (int i = 0; i < array.length(); i++) presets.add(PresetList.from(array.getJSONObject(i)));
            } catch (Exception ignored) {
                presets.clear();
            }
        }
        if (presets.isEmpty()) {
            presets.add(new PresetList("Compra semanal", "preset_weekly", Arrays.asList("Pan", "Leche", "Huevos", "Tomates", "Platanos", "Detergente")));
            presets.add(new PresetList("Desayuno", "preset_breakfast", Arrays.asList("Pan", "Leche", "Huevos")));
            presets.add(new PresetList("Limpieza", "preset_cleaning", Arrays.asList("Detergente", "Papel higienico")));
            presets.add(new PresetList("Cena rapida", "preset_dinner", Arrays.asList("Aceite de oliva", "Tomates", "Pan")));
        }
    }

    private void loadMembers() {
        members.clear();
        String raw = prefs.getString("members", "");
        if (!raw.isEmpty()) {
            try {
                JSONArray array = new JSONArray(raw);
                for (int i = 0; i < array.length(); i++) members.add(Member.from(array.getJSONObject(i)));
            } catch (Exception ignored) {
                members.clear();
            }
        }
        if (members.isEmpty()) {
            members.add(new Member("Tu", "Propietario"));
            members.add(new Member("Laura", "Puede editar"));
        }
    }

    private void save() {
        JSONArray productsJson = new JSONArray();
        JSONArray listsJson = new JSONArray();
        JSONArray presetsJson = new JSONArray();
        JSONArray membersJson = new JSONArray();
        try {
            for (Product product : products) productsJson.put(product.toJson());
            for (ShoppingList list : lists) listsJson.put(list.toJson());
            for (PresetList preset : presets) presetsJson.put(preset.toJson());
            for (Member member : members) membersJson.put(member.toJson());
        } catch (Exception ignored) { }
        prefs.edit()
            .putString("products.v2", productsJson.toString())
            .putString("lists.v2", listsJson.toString())
            .putString("presets.v2", presetsJson.toString())
            .putString("members", membersJson.toString())
            .putString("activeListId.v2", activeListId)
            .putBoolean("canEdit", canEdit)
            .apply();
    }

    private View metric(String title, String value) {
        LinearLayout box = new LinearLayout(this);
        box.setOrientation(LinearLayout.VERTICAL);
        box.setPadding(dp(12), dp(10), dp(12), dp(10));
        box.setBackground(rounded(surface, 8));
        box.addView(label(title, 12, muted, true));
        box.addView(label(value, 22, text, true));
        return box;
    }

    private TextView section(String value) {
        TextView title = label(value, 18, text, true);
        title.setPadding(0, dp(4), 0, dp(10));
        return title;
    }

    private View chip(String value) {
        TextView chip = label(value, 13, accent, true);
        chip.setGravity(Gravity.CENTER);
        chip.setPadding(dp(12), 0, dp(12), 0);
        chip.setBackground(rounded(withAlpha(accent, 32), 18));
        chip.setMinHeight(dp(34));
        return chip;
    }

    private View empty(String value) {
        TextView empty = label(value, 15, muted, false);
        empty.setGravity(Gravity.CENTER);
        empty.setBackground(rounded(surface, 8));
        return withBottom(empty, 10);
    }

    private LinearLayout card() {
        LinearLayout card = new LinearLayout(this);
        card.setOrientation(LinearLayout.VERTICAL);
        card.setPadding(dp(16), dp(16), dp(16), dp(16));
        card.setBackground(rounded(surface, 8));
        return card;
    }

    private Button actionButton(String title, View.OnClickListener listener) {
        Button button = new Button(this);
        button.setText(title);
        button.setTextSize(15);
        button.setTextColor(text);
        button.setTypeface(Typeface.DEFAULT_BOLD);
        button.setAllCaps(false);
        button.setBackground(rounded(surface, 8));
        button.setOnClickListener(listener);
        return button;
    }

    private Button textButton(String title, View.OnClickListener listener) {
        Button button = new Button(this);
        button.setText(title);
        button.setTextColor(accent);
        button.setTextSize(13);
        button.setTypeface(Typeface.DEFAULT_BOLD);
        button.setAllCaps(false);
        button.setBackground(rounded(surfaceSoft, 8));
        button.setOnClickListener(listener);
        return button;
    }

    private TextView label(String value, int sp, int color, boolean bold) {
        TextView label = new TextView(this);
        label.setText(value);
        label.setTextSize(sp);
        label.setTextColor(color);
        label.setIncludeFontPadding(true);
        if (bold) label.setTypeface(Typeface.DEFAULT_BOLD);
        return label;
    }

    private EditText input(String hint) {
        EditText input = new EditText(this);
        input.setHint(hint);
        input.setSingleLine(true);
        return input;
    }

    private LinearLayout dialogForm() {
        LinearLayout form = new LinearLayout(this);
        form.setOrientation(LinearLayout.VERTICAL);
        form.setPadding(dp(18), dp(8), dp(18), 0);
        return form;
    }

    private String initials(String name) {
        String[] parts = name.trim().split("\\s+");
        String result = "";
        for (int i = 0; i < Math.min(2, parts.length); i++) {
            if (!parts[i].isEmpty()) result += parts[i].substring(0, 1).toUpperCase(Locale.ROOT);
        }
        return result.isEmpty() ? "?" : result;
    }

    private String blankTo(String value, String fallback) {
        String cleaned = value.trim();
        return cleaned.isEmpty() ? fallback : cleaned;
    }

    private View withBottom(View view, int bottom) {
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(-1, -2);
        lp.setMargins(0, 0, 0, dp(bottom));
        view.setLayoutParams(lp);
        return view;
    }

    private View withTop(View view, int top) {
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(-1, -2);
        lp.setMargins(0, dp(top), 0, 0);
        view.setLayoutParams(lp);
        return view;
    }

    private View withLeft(View view, int left) {
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(-2, -2);
        lp.setMargins(dp(left), 0, 0, 0);
        view.setLayoutParams(lp);
        return view;
    }

    private GradientDrawable rounded(int color, int radius) {
        GradientDrawable drawable = new GradientDrawable();
        drawable.setColor(color);
        drawable.setCornerRadius(dp(radius));
        return drawable;
    }

    private int withAlpha(int color, int alpha) {
        return Color.argb(alpha, Color.red(color), Color.green(color), Color.blue(color));
    }

    private int dp(int value) {
        return (int) (value * getResources().getDisplayMetrics().density + 0.5f);
    }

    private static final class Product {
        final String id;
        final String name;
        final String category;
        final String unit;
        final String imageName;
        final String emoji;
        final String imageUri;

        Product(String name, String category, String unit, String imageName, String emoji) {
            this(UUID.randomUUID().toString(), name, category, unit, imageName, emoji, "");
        }

        Product(String name, String category, String unit, String imageName, String emoji, String imageUri) {
            this(UUID.randomUUID().toString(), name, category, unit, imageName, emoji, imageUri);
        }

        Product(String id, String name, String category, String unit, String imageName, String emoji, String imageUri) {
            this.id = id;
            this.name = name;
            this.category = category;
            this.unit = unit;
            this.imageName = imageName == null || imageName.trim().isEmpty() ? defaultImage(name) : imageName;
            this.emoji = emoji == null ? "" : emoji;
            this.imageUri = imageUri == null ? "" : imageUri;
        }

        JSONObject toJson() throws Exception {
            JSONObject json = new JSONObject();
            json.put("id", id);
            json.put("name", name);
            json.put("category", category);
            json.put("unit", unit);
            json.put("imageName", imageName);
            json.put("emoji", emoji);
            json.put("imageUri", imageUri);
            return json;
        }

        static Product from(JSONObject json) {
            return new Product(
                json.optString("id", UUID.randomUUID().toString()),
                json.optString("name"),
                json.optString("category", "Otros"),
                json.optString("unit", "ud"),
                json.optString("imageName", defaultImage(json.optString("name"))),
                json.optString("emoji", ""),
                json.optString("imageUri", "")
            );
        }

        static String defaultImage(String name) {
            String key = name == null ? "" : name.toLowerCase(Locale.ROOT);
            if (key.contains("leche")) return "product_milk";
            if (key.contains("pan")) return "product_bread";
            if (key.contains("huevo")) return "product_eggs";
            if (key.contains("tomate")) return "product_tomato";
            if (key.contains("platano") || key.contains("banana")) return "product_banana";
            if (key.contains("manzana")) return "product_apple";
            if (key.contains("detergente")) return "product_detergent";
            if (key.contains("papel")) return "product_paper";
            if (key.contains("aceite")) return "product_oil";
            if (key.contains("queso")) return "product_cheese";
            if (key.contains("yogur")) return "product_yogurt";
            if (key.contains("mantequilla")) return "product_butter";
            if (key.contains("pollo")) return "product_chicken";
            if (key.contains("pescado") || key.contains("atun")) return "product_fish";
            if (key.contains("carne") || key.contains("filete")) return "product_meat";
            if (key.contains("jamon") || key.contains("pavo")) return "product_ham";
            if (key.contains("congel")) return "product_frozen";
            if (key.contains("arroz")) return "product_rice";
            if (key.contains("pasta") || key.contains("macarr")) return "product_pasta";
            if (key.contains("harina")) return "product_flour";
            if (key.contains("azucar")) return "product_sugar";
            if (key.contains("sal")) return "product_salt";
            if (key.contains("cafe")) return "product_coffee";
            if (key.contains("te") || key.contains("infusion")) return "product_tea";
            if (key.contains("cereal")) return "product_cereal";
            if (key.contains("agua")) return "product_water";
            if (key.contains("zumo") || key.contains("jugo")) return "product_juice";
            if (key.contains("refresco") || key.contains("soda")) return "product_soda";
            if (key.contains("vino")) return "product_wine";
            if (key.contains("jabon")) return "product_soap";
            if (key.contains("champu")) return "product_shampoo";
            if (key.contains("dientes") || key.contains("dentifrico") || key.contains("pasta dental")) return "product_toothpaste";
            if (key.contains("wc") || key.contains("inodoro")) return "product_toilet_cleaner";
            if (key.contains("basura")) return "product_trash_bags";
            if (key.contains("esponja")) return "product_sponge";
            if (key.contains("lavavajillas")) return "product_dish_soap";
            if (key.contains("suavizante")) return "product_softener";
            if (key.contains("panal") || key.contains("pañal")) return "product_diapers";
            if (key.contains("mascota") || key.contains("perro") || key.contains("gato")) return "product_pet_food";
            if (key.contains("bebe") || key.contains("bebé")) return "product_baby_food";
            if (key.contains("medicina") || key.contains("botiquin")) return "product_medicine";
            return "product_default";
        }
    }

    private static final class ShoppingItem {
        final String id;
        final Product product;
        int quantity;
        boolean checked;

        ShoppingItem(Product product, int quantity, boolean checked) {
            this(UUID.randomUUID().toString(), product, quantity, checked);
        }

        ShoppingItem(String id, Product product, int quantity, boolean checked) {
            this.id = id;
            this.product = product;
            this.quantity = quantity;
            this.checked = checked;
        }

        JSONObject toJson() throws Exception {
            JSONObject json = new JSONObject();
            json.put("id", id);
            json.put("product", product.toJson());
            json.put("quantity", quantity);
            json.put("checked", checked);
            return json;
        }

        static ShoppingItem from(JSONObject json) throws Exception {
            return new ShoppingItem(
                json.optString("id", UUID.randomUUID().toString()),
                Product.from(json.getJSONObject("product")),
                json.optInt("quantity", 1),
                json.optBoolean("checked", false)
            );
        }
    }

    private static final class ShoppingList {
        final String id;
        final String name;
        final ArrayList<ShoppingItem> items = new ArrayList<>();

        ShoppingList(String name) {
            this(UUID.randomUUID().toString(), name);
        }

        ShoppingList(String id, String name) {
            this.id = id;
            this.name = name;
        }

        JSONObject toJson() throws Exception {
            JSONObject json = new JSONObject();
            json.put("id", id);
            json.put("name", name);
            JSONArray itemJson = new JSONArray();
            for (ShoppingItem item : items) itemJson.put(item.toJson());
            json.put("items", itemJson);
            return json;
        }

        static ShoppingList from(JSONObject json) throws Exception {
            ShoppingList list = new ShoppingList(json.optString("id", UUID.randomUUID().toString()), json.optString("name", "Lista"));
            JSONArray array = json.optJSONArray("items");
            if (array != null) {
                for (int i = 0; i < array.length(); i++) list.items.add(ShoppingItem.from(array.getJSONObject(i)));
            }
            return list;
        }
    }

    private static final class PresetList {
        String name;
        final String imageName;
        final ArrayList<String> productNames;

        PresetList(String name, String imageName, java.util.List<String> productNames) {
            this.name = name;
            this.imageName = imageName;
            this.productNames = new ArrayList<>(productNames);
        }

        JSONObject toJson() throws Exception {
            JSONObject json = new JSONObject();
            json.put("name", name);
            json.put("imageName", imageName);
            JSONArray names = new JSONArray();
            for (String productName : productNames) names.put(productName);
            json.put("productNames", names);
            return json;
        }

        static PresetList from(JSONObject json) {
            ArrayList<String> names = new ArrayList<>();
            JSONArray array = json.optJSONArray("productNames");
            if (array != null) {
                for (int i = 0; i < array.length(); i++) names.add(array.optString(i));
            }
            return new PresetList(json.optString("name", "Lista"), json.optString("imageName", "preset_weekly"), names);
        }
    }

    private static final class Member {
        final String name;
        final String permission;

        Member(String name, String permission) {
            this.name = name;
            this.permission = permission;
        }

        JSONObject toJson() throws Exception {
            JSONObject json = new JSONObject();
            json.put("name", name);
            json.put("permission", permission);
            return json;
        }

        static Member from(JSONObject json) {
            return new Member(json.optString("name", "Persona"), json.optString("permission", "Puede editar"));
        }
    }
}
