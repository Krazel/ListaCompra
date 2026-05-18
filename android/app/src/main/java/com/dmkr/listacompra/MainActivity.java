package com.dmkr.listacompra;

import android.app.AlertDialog;
import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.text.InputType;
import android.view.Gravity;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.GridLayout;
import android.widget.HorizontalScrollView;
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

    private final ArrayList<Product> products = new ArrayList<>();
    private final ArrayList<ShoppingItem> items = new ArrayList<>();
    private final ArrayList<PresetList> presets = new ArrayList<>();
    private final ArrayList<Member> members = new ArrayList<>();

    private SharedPreferences prefs;
    private int currentTab = 0;
    private boolean canEdit = true;
    private int quantity = 1;

    private final int background = Color.parseColor("#050806");
    private final int surface = Color.parseColor("#171B18");
    private final int surfaceSoft = Color.parseColor("#202720");
    private final int text = Color.parseColor("#F1F5F0");
    private final int muted = Color.parseColor("#9CA69D");
    private final int accent = Color.parseColor("#23C16B");
    private final int danger = Color.parseColor("#E34E49");
    private final int[] iconColors = {
        Color.parseColor("#8BC49F"),
        Color.parseColor("#EE9D48"),
        Color.parseColor("#5AADE8"),
        Color.parseColor("#EBC65A"),
        Color.parseColor("#E75D52"),
        Color.parseColor("#9DC65E")
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        prefs = getSharedPreferences(PREFS, MODE_PRIVATE);
        load();
        render();
    }

    private void render() {
        FrameLayout frame = new FrameLayout(this);
        frame.setBackgroundColor(background);

        ScrollView scroll = new ScrollView(this);
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setPadding(dp(20), dp(36), dp(20), dp(96));
        scroll.addView(root);
        frame.addView(scroll);

        if (currentTab == 0) showList(root);
        if (currentTab == 1) showAdd(root);
        if (currentTab == 2) showPresets(root);
        if (currentTab == 3) showShare(root);

        frame.addView(bottomNav(), new FrameLayout.LayoutParams(-1, dp(72), Gravity.BOTTOM));
        setContentView(frame);
    }

    private void showList(LinearLayout root) {
        root.addView(header("Lista de la compra", pendingCount() + " pendientes"));
        LinearLayout chips = new LinearLayout(this);
        chips.setOrientation(LinearLayout.HORIZONTAL);
        chips.addView(chip("Compartida"));
        chips.addView(withLeft(chip(members.size() + " personas"), 8));
        root.addView(withBottom(chips, 14));

        LinearLayout metrics = new LinearLayout(this);
        metrics.setOrientation(LinearLayout.HORIZONTAL);
        metrics.addView(metric("Total", String.valueOf(items.size())), new LinearLayout.LayoutParams(0, dp(78), 1));
        metrics.addView(withLeft(metric("Pendiente", String.valueOf(pendingCount())), 10), new LinearLayout.LayoutParams(0, dp(78), 1));
        metrics.addView(withLeft(metric("Hecho", String.valueOf(doneCount())), 10), new LinearLayout.LayoutParams(0, dp(78), 1));
        root.addView(withBottom(metrics, 18));

        root.addView(section("Por comprar"));
        int pending = 0;
        for (ShoppingItem item : items) {
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
            Button clear = textButton("Limpiar", v -> {
                items.removeIf(i -> i.checked);
                save();
                render();
            });
            doneHeader.addView(clear, new LinearLayout.LayoutParams(dp(98), dp(42)));
            root.addView(withTop(doneHeader, 8));
            for (ShoppingItem item : items) {
                if (item.checked) root.addView(itemRow(item));
            }
        }
    }

    private void showAdd(LinearLayout root) {
        root.addView(header("Anadir productos", "Elige del catalogo y ajusta la cantidad."));
        Button search = actionButton("Buscar producto", v -> showSearchDialog());
        root.addView(withBottom(search, 12), new LinearLayout.LayoutParams(-1, dp(48)));

        LinearLayout qty = card();
        LinearLayout row = new LinearLayout(this);
        row.setGravity(Gravity.CENTER_VERTICAL);
        row.addView(label("Cantidad", 15, text, true), new LinearLayout.LayoutParams(0, -2, 1));
        row.addView(textButton("-", v -> {
            quantity = Math.max(1, quantity - 1);
            render();
        }), new LinearLayout.LayoutParams(dp(46), dp(40)));
        TextView value = label(String.valueOf(quantity), 18, text, true);
        value.setGravity(Gravity.CENTER);
        row.addView(value, new LinearLayout.LayoutParams(dp(46), dp(40)));
        row.addView(textButton("+", v -> {
            quantity++;
            render();
        }), new LinearLayout.LayoutParams(dp(46), dp(40)));
        qty.addView(row);
        root.addView(withBottom(qty, 14));

        GridLayout grid = new GridLayout(this);
        grid.setColumnCount(2);
        for (Product product : products) {
            GridLayout.LayoutParams lp = new GridLayout.LayoutParams();
            lp.width = (getResources().getDisplayMetrics().widthPixels - dp(52)) / 2;
            lp.height = dp(154);
            lp.setMargins(0, 0, dp(12), dp(12));
            grid.addView(productCard(product), lp);
        }
        root.addView(grid);

        LinearLayout custom = card();
        custom.addView(label("Crear producto", 18, text, true));
        Button create = actionButton("Nuevo producto", v -> showCreateProductDialog());
        custom.addView(withTop(create, 12), new LinearLayout.LayoutParams(-1, dp(48)));
        root.addView(withTop(custom, 4));
    }

    private void showPresets(LinearLayout root) {
        root.addView(header("Listas base", "Plantillas personales para repetir compras."));
        for (PresetList preset : presets) root.addView(presetCard(preset));
    }

    private void showShare(LinearLayout root) {
        root.addView(header("Compartida", "Gestiona personas y envia la lista."));
        LinearLayout panel = card();
        LinearLayout top = new LinearLayout(this);
        top.setGravity(Gravity.CENTER_VERTICAL);
        top.addView(label(members.size() + " personas", 18, text, true), new LinearLayout.LayoutParams(0, -2, 1));
        top.addView(textButton("Enviar", v -> shareList()), new LinearLayout.LayoutParams(dp(108), dp(42)));
        panel.addView(top);
        Button edit = actionButton(canEdit ? "Permitir edicion: si" : "Permitir edicion: no", v -> {
            canEdit = !canEdit;
            save();
            render();
        });
        panel.addView(withTop(edit, 12), new LinearLayout.LayoutParams(-1, dp(48)));
        Button invite = actionButton("Invitar", v -> showInviteDialog());
        panel.addView(withTop(invite, 10), new LinearLayout.LayoutParams(-1, dp(48)));
        root.addView(withBottom(panel, 14));

        for (Member member : members) root.addView(memberRow(member));

        LinearLayout preview = card();
        preview.addView(label("Vista previa", 18, text, true));
        TextView copy = label(shareText(), 14, muted, false);
        copy.setPadding(0, dp(10), 0, 0);
        preview.addView(copy);
        root.addView(withTop(preview, 8));
    }

    private View itemRow(ShoppingItem item) {
        LinearLayout row = new LinearLayout(this);
        row.setGravity(Gravity.CENTER_VERTICAL);
        row.setPadding(dp(12), dp(12), dp(12), dp(12));
        row.setBackground(rounded(surface, 8));

        Button check = textButton(item.checked ? "✓" : "○", v -> {
            item.checked = !item.checked;
            save();
            render();
        });
        row.addView(check, new LinearLayout.LayoutParams(dp(42), dp(42)));
        row.addView(productIcon(item.product, 42));

        LinearLayout copy = new LinearLayout(this);
        copy.setOrientation(LinearLayout.VERTICAL);
        copy.setPadding(dp(10), 0, 0, 0);
        copy.addView(label(item.product.name, 16, item.checked ? muted : text, true));
        copy.addView(label(item.product.category, 13, muted, false));
        row.addView(copy, new LinearLayout.LayoutParams(0, -2, 1));

        row.addView(textButton("-", v -> {
            item.quantity = Math.max(1, item.quantity - 1);
            save();
            render();
        }), new LinearLayout.LayoutParams(dp(34), dp(38)));
        TextView qty = label(item.quantity + " " + item.product.unit, 13, text, true);
        qty.setGravity(Gravity.CENTER);
        row.addView(qty, new LinearLayout.LayoutParams(dp(56), dp(38)));
        row.addView(textButton("+", v -> {
            item.quantity++;
            save();
            render();
        }), new LinearLayout.LayoutParams(dp(34), dp(38)));
        row.addView(textButton("🗑", v -> {
            items.remove(item);
            save();
            render();
        }), new LinearLayout.LayoutParams(dp(42), dp(38)));
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
            render();
        });
        card.addView(productIcon(product, 46));
        card.addView(withTop(label(product.name, 16, text, true), 10));
        card.addView(label(product.category, 12, muted, true));
        TextView add = label("+ Anadir", 13, accent, true);
        add.setPadding(0, dp(12), 0, 0);
        card.addView(add);
        return card;
    }

    private View presetCard(PresetList preset) {
        LinearLayout card = card();
        LinearLayout row = new LinearLayout(this);
        row.setGravity(Gravity.CENTER_VERTICAL);
        TextView icon = label(preset.icon, 20, accent, true);
        icon.setGravity(Gravity.CENTER);
        icon.setBackground(rounded(withAlpha(accent, 32), 8));
        row.addView(icon, new LinearLayout.LayoutParams(dp(46), dp(46)));

        LinearLayout copy = new LinearLayout(this);
        copy.setOrientation(LinearLayout.VERTICAL);
        copy.setPadding(dp(12), 0, 0, 0);
        copy.addView(label(preset.name, 19, text, true));
        copy.addView(label(preset.productNames.size() + " productos", 13, muted, false));
        row.addView(copy, new LinearLayout.LayoutParams(0, -2, 1));
        row.addView(textButton("Usar", v -> {
            for (String name : preset.productNames) {
                Product p = findProduct(name);
                if (p != null) addProduct(p, 1);
            }
            save();
            Toast.makeText(this, "Lista anadida", Toast.LENGTH_SHORT).show();
            currentTab = 0;
            render();
        }), new LinearLayout.LayoutParams(dp(84), dp(42)));
        card.addView(row);

        LinearLayout icons = new LinearLayout(this);
        icons.setPadding(0, dp(12), 0, 0);
        for (String name : preset.productNames) {
            Product product = findProduct(name);
            if (product != null) icons.addView(productIcon(product, 32));
        }
        card.addView(icons);
        return withBottom(card, 12);
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
        row.addView(textButton("Borrar", v -> {
            members.remove(member);
            save();
            render();
        }), new LinearLayout.LayoutParams(dp(86), dp(42)));
        return withBottom(row, 10);
    }

    private View header(String title, String subtitle) {
        LinearLayout box = new LinearLayout(this);
        box.setOrientation(LinearLayout.VERTICAL);
        box.setPadding(0, 0, 0, dp(16));
        box.addView(label(title, 30, text, true));
        box.addView(label(subtitle, 15, muted, false));
        return box;
    }

    private View bottomNav() {
        LinearLayout nav = new LinearLayout(this);
        nav.setGravity(Gravity.CENTER);
        nav.setPadding(dp(6), dp(6), dp(6), dp(6));
        nav.setBackgroundColor(surface);
        String[] labels = {"Lista", "Anadir", "Listas", "Compartir"};
        for (int i = 0; i < labels.length; i++) {
            final int tab = i;
            TextView item = label(labels[i], 12, currentTab == tab ? accent : muted, true);
            item.setGravity(Gravity.CENTER);
            item.setOnClickListener(v -> {
                currentTab = tab;
                render();
            });
            nav.addView(item, new LinearLayout.LayoutParams(0, -1, 1));
        }
        return nav;
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

    private View productIcon(Product product, int size) {
        TextView icon = label(product.icon, Math.max(14, size / 2), iconColors[product.tint % iconColors.length], true);
        icon.setGravity(Gravity.CENTER);
        icon.setBackground(rounded(withAlpha(iconColors[product.tint % iconColors.length], 36), 8));
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(dp(size), dp(size));
        lp.setMargins(0, 0, dp(6), 0);
        icon.setLayoutParams(lp);
        return icon;
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
        button.setTextSize(14);
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

    private void showSearchDialog() {
        EditText input = new EditText(this);
        input.setHint("Buscar producto");
        input.setTextColor(Color.BLACK);
        input.setSingleLine(true);
        new AlertDialog.Builder(this)
            .setTitle("Buscar producto")
            .setView(input)
            .setNegativeButton("Cancelar", null)
            .setPositiveButton("Buscar", (dialog, which) -> {
                String query = input.getText().toString().trim().toLowerCase(Locale.ROOT);
                Product product = null;
                for (Product candidate : products) {
                    if (candidate.name.toLowerCase(Locale.ROOT).contains(query) || candidate.category.toLowerCase(Locale.ROOT).contains(query)) {
                        product = candidate;
                        break;
                    }
                }
                if (product != null) {
                    addProduct(product, quantity);
                    Toast.makeText(this, product.name + " anadido", Toast.LENGTH_SHORT).show();
                    render();
                }
            })
            .show();
    }

    private void showCreateProductDialog() {
        LinearLayout form = new LinearLayout(this);
        form.setOrientation(LinearLayout.VERTICAL);
        form.setPadding(dp(18), dp(8), dp(18), 0);
        EditText name = new EditText(this);
        name.setHint("Nombre");
        EditText category = new EditText(this);
        category.setHint("Categoria");
        form.addView(name);
        form.addView(category);
        new AlertDialog.Builder(this)
            .setTitle("Nuevo producto")
            .setView(form)
            .setNegativeButton("Cancelar", null)
            .setPositiveButton("Guardar", (dialog, which) -> {
                String cleaned = name.getText().toString().trim();
                if (!cleaned.isEmpty()) {
                    products.add(new Product(cleaned, category.getText().toString().trim().isEmpty() ? "Otros" : category.getText().toString().trim(), "ud", "*", products.size() % iconColors.length));
                    save();
                    render();
                }
            })
            .show();
    }

    private void showInviteDialog() {
        EditText input = new EditText(this);
        input.setHint("Nombre");
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
        for (ShoppingItem item : items) {
            if (item.product.name.equals(product.name) && !item.checked) {
                item.quantity += Math.max(1, amount);
                save();
                return;
            }
        }
        items.add(0, new ShoppingItem(product, Math.max(1, amount), false));
        save();
    }

    private Product findProduct(String name) {
        for (Product product : products) if (product.name.equals(name)) return product;
        return null;
    }

    private int pendingCount() {
        int count = 0;
        for (ShoppingItem item : items) if (!item.checked) count++;
        return count;
    }

    private int doneCount() {
        int count = 0;
        for (ShoppingItem item : items) if (item.checked) count++;
        return count;
    }

    private String shareText() {
        StringBuilder builder = new StringBuilder("Lista de la compra\n");
        for (ShoppingItem item : items) {
            builder.append("- ")
                .append(item.product.name)
                .append(": ")
                .append(item.quantity)
                .append(" ")
                .append(item.product.unit);
            if (item.checked) builder.append(" (comprado)");
            builder.append("\n");
        }
        return builder.toString();
    }

    private String initials(String name) {
        String[] parts = name.trim().split("\\s+");
        String result = "";
        for (int i = 0; i < Math.min(2, parts.length); i++) {
            if (!parts[i].isEmpty()) result += parts[i].substring(0, 1).toUpperCase(Locale.ROOT);
        }
        return result.isEmpty() ? "?" : result;
    }

    private void load() {
        loadProducts();
        loadItems();
        loadPresets();
        loadMembers();
        canEdit = prefs.getBoolean("canEdit", true);
    }

    private void loadProducts() {
        products.clear();
        String raw = prefs.getString("products", "");
        if (!raw.isEmpty()) {
            try {
                JSONArray array = new JSONArray(raw);
                for (int i = 0; i < array.length(); i++) products.add(Product.from(array.getJSONObject(i)));
            } catch (Exception ignored) {
                products.clear();
            }
        }
        if (products.isEmpty()) {
            products.add(new Product("Pan", "Despensa", "ud", "▰", 1));
            products.add(new Product("Leche", "Frescos", "l", "◖", 2));
            products.add(new Product("Huevos", "Frescos", "doc", "○", 3));
            products.add(new Product("Tomates", "Frescos", "ud", "●", 4));
            products.add(new Product("Platanos", "Fruta", "ud", "◠", 5));
            products.add(new Product("Manzanas", "Fruta", "kg", "◆", 4));
            products.add(new Product("Arroz", "Despensa", "kg", "□", 1));
            products.add(new Product("Pasta", "Despensa", "paq", "≋", 1));
            products.add(new Product("Cafe", "Desayuno", "paq", "◡", 1));
            products.add(new Product("Detergente", "Limpieza", "ud", "✦", 2));
            products.add(new Product("Papel cocina", "Limpieza", "paq", "▣", 0));
            products.add(new Product("Congelados", "Congelador", "bol", "✳", 2));
        }
    }

    private void loadItems() {
        items.clear();
        String raw = prefs.getString("items", "");
        if (!raw.isEmpty()) {
            try {
                JSONArray array = new JSONArray(raw);
                for (int i = 0; i < array.length(); i++) items.add(ShoppingItem.from(array.getJSONObject(i)));
            } catch (Exception ignored) {
                items.clear();
            }
        }
        if (items.isEmpty()) {
            for (String name : Arrays.asList("Pan", "Leche", "Huevos", "Tomates")) {
                Product product = findProduct(name);
                if (product != null) items.add(new ShoppingItem(product, name.equals("Huevos") ? 1 : 2, false));
            }
        }
    }

    private void loadPresets() {
        presets.clear();
        presets.add(new PresetList("Compra semanal", "▦", Arrays.asList("Pan", "Leche", "Huevos", "Tomates", "Platanos", "Arroz")));
        presets.add(new PresetList("Desayuno", "☼", Arrays.asList("Pan", "Leche", "Cafe", "Huevos")));
        presets.add(new PresetList("Limpieza", "✦", Arrays.asList("Detergente", "Papel cocina")));
        presets.add(new PresetList("Cena rapida", "◷", Arrays.asList("Pasta", "Tomates", "Congelados")));
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
            members.add(new Member("Yo", "Puede editar"));
            members.add(new Member("Casa", "Puede editar"));
        }
    }

    private void save() {
        JSONArray productsJson = new JSONArray();
        JSONArray itemsJson = new JSONArray();
        JSONArray membersJson = new JSONArray();
        try {
            for (Product product : products) productsJson.put(product.toJson());
            for (ShoppingItem item : items) itemsJson.put(item.toJson());
            for (Member member : members) membersJson.put(member.toJson());
        } catch (Exception ignored) { }
        prefs.edit()
            .putString("products", productsJson.toString())
            .putString("items", itemsJson.toString())
            .putString("members", membersJson.toString())
            .putBoolean("canEdit", canEdit)
            .apply();
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
        final String icon;
        final int tint;

        Product(String name, String category, String unit, String icon, int tint) {
            this.id = UUID.randomUUID().toString();
            this.name = name;
            this.category = category;
            this.unit = unit;
            this.icon = icon;
            this.tint = tint;
        }

        Product(String id, String name, String category, String unit, String icon, int tint) {
            this.id = id;
            this.name = name;
            this.category = category;
            this.unit = unit;
            this.icon = icon;
            this.tint = tint;
        }

        JSONObject toJson() throws Exception {
            JSONObject json = new JSONObject();
            json.put("id", id);
            json.put("name", name);
            json.put("category", category);
            json.put("unit", unit);
            json.put("icon", icon);
            json.put("tint", tint);
            return json;
        }

        static Product from(JSONObject json) {
            return new Product(
                json.optString("id", UUID.randomUUID().toString()),
                json.optString("name"),
                json.optString("category", "Otros"),
                json.optString("unit", "ud"),
                json.optString("icon", "*"),
                json.optInt("tint", 0)
            );
        }
    }

    private static final class ShoppingItem {
        final String id;
        final Product product;
        int quantity;
        boolean checked;

        ShoppingItem(Product product, int quantity, boolean checked) {
            this.id = UUID.randomUUID().toString();
            this.product = product;
            this.quantity = quantity;
            this.checked = checked;
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

    private static final class PresetList {
        final String name;
        final String icon;
        final ArrayList<String> productNames;

        PresetList(String name, String icon, java.util.List<String> productNames) {
            this.name = name;
            this.icon = icon;
            this.productNames = new ArrayList<>(productNames);
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
