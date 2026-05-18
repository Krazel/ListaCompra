import SwiftUI
import UIKit

@main
struct ListaCompraApp: App {
  @StateObject private var store = ShoppingStore()

  var body: some Scene {
    WindowGroup {
      RootView()
        .environmentObject(store)
        .preferredColorScheme(.dark)
    }
  }
}

struct Product: Identifiable, Codable, Equatable {
  let id: UUID
  var name: String
  var category: String
  var unit: String
  var icon: String
  var assetName: String
  var emoji: String
  var tint: Int

  init(id: UUID = UUID(), name: String, category: String, unit: String, icon: String, assetName: String = "product_default", emoji: String = "", tint: Int) {
    self.id = id
    self.name = name
    self.category = category
    self.unit = unit
    self.icon = icon
    self.assetName = assetName
    self.emoji = emoji
    self.tint = tint
  }

  enum CodingKeys: String, CodingKey {
    case id, name, category, unit, icon, assetName, emoji, tint
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
    name = try values.decode(String.self, forKey: .name)
    category = try values.decodeIfPresent(String.self, forKey: .category) ?? "Otros"
    unit = try values.decodeIfPresent(String.self, forKey: .unit) ?? "ud"
    icon = try values.decodeIfPresent(String.self, forKey: .icon) ?? "cart"
    assetName = try values.decodeIfPresent(String.self, forKey: .assetName) ?? Self.defaultAsset(for: name)
    emoji = try values.decodeIfPresent(String.self, forKey: .emoji) ?? ""
    tint = try values.decodeIfPresent(Int.self, forKey: .tint) ?? 0
  }

  static func defaultAsset(for name: String) -> String {
    let key = name.lowercased()
    if key.contains("leche") { return "product_milk" }
    if key.contains("pan") { return "product_bread" }
    if key.contains("huevo") { return "product_eggs" }
    if key.contains("tomate") { return "product_tomato" }
    if key.contains("platano") || key.contains("banana") { return "product_banana" }
    if key.contains("manzana") { return "product_apple" }
    if key.contains("detergente") { return "product_detergent" }
    if key.contains("papel") { return "product_paper" }
    if key.contains("aceite") { return "product_oil" }
    if key.contains("queso") { return "product_cheese" }
    if key.contains("yogur") { return "product_yogurt" }
    if key.contains("mantequilla") { return "product_butter" }
    if key.contains("pollo") { return "product_chicken" }
    if key.contains("pescado") || key.contains("atun") { return "product_fish" }
    if key.contains("carne") || key.contains("filete") { return "product_meat" }
    if key.contains("jamon") || key.contains("pavo") { return "product_ham" }
    if key.contains("congel") { return "product_frozen" }
    if key.contains("arroz") { return "product_rice" }
    if key.contains("pasta") || key.contains("macarr") { return "product_pasta" }
    if key.contains("harina") { return "product_flour" }
    if key.contains("azucar") { return "product_sugar" }
    if key.contains("sal") { return "product_salt" }
    if key.contains("cafe") { return "product_coffee" }
    if key.contains("te") || key.contains("infusion") { return "product_tea" }
    if key.contains("cereal") { return "product_cereal" }
    if key.contains("agua") { return "product_water" }
    if key.contains("zumo") || key.contains("jugo") { return "product_juice" }
    if key.contains("refresco") || key.contains("soda") { return "product_soda" }
    if key.contains("vino") { return "product_wine" }
    if key.contains("jabon") { return "product_soap" }
    if key.contains("champu") { return "product_shampoo" }
    if key.contains("dientes") || key.contains("dentifrico") || key.contains("pasta dental") { return "product_toothpaste" }
    if key.contains("wc") || key.contains("inodoro") { return "product_toilet_cleaner" }
    if key.contains("basura") { return "product_trash_bags" }
    if key.contains("esponja") { return "product_sponge" }
    if key.contains("lavavajillas") { return "product_dish_soap" }
    if key.contains("suavizante") { return "product_softener" }
    if key.contains("panal") || key.contains("pañal") { return "product_diapers" }
    if key.contains("mascota") || key.contains("perro") || key.contains("gato") { return "product_pet_food" }
    if key.contains("bebe") || key.contains("bebé") { return "product_baby_food" }
    if key.contains("medicina") || key.contains("botiquin") { return "product_medicine" }
    return "product_default"
  }
}

struct ShoppingItem: Identifiable, Codable, Equatable {
  let id: UUID
  var product: Product
  var quantity: Int
  var checked: Bool

  init(id: UUID = UUID(), product: Product, quantity: Int = 1, checked: Bool = false) {
    self.id = id
    self.product = product
    self.quantity = quantity
    self.checked = checked
  }
}

struct ShoppingList: Identifiable, Codable, Equatable {
  let id: UUID
  var name: String
  var items: [ShoppingItem]
  var isShared: Bool

  init(id: UUID = UUID(), name: String, items: [ShoppingItem] = [], isShared: Bool = true) {
    self.id = id
    self.name = name
    self.items = items
    self.isShared = isShared
  }
}

struct PresetList: Identifiable, Codable, Equatable {
  let id: UUID
  var name: String
  var icon: String
  var assetName: String
  var productNames: [String]

  init(id: UUID = UUID(), name: String, icon: String, assetName: String = "preset_weekly", productNames: [String]) {
    self.id = id
    self.name = name
    self.icon = icon
    self.assetName = assetName
    self.productNames = productNames
  }

  enum CodingKeys: String, CodingKey {
    case id, name, icon, assetName, productNames
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
    name = try values.decode(String.self, forKey: .name)
    icon = try values.decodeIfPresent(String.self, forKey: .icon) ?? "star"
    assetName = try values.decodeIfPresent(String.self, forKey: .assetName) ?? "preset_weekly"
    productNames = try values.decodeIfPresent([String].self, forKey: .productNames) ?? []
  }
}

struct SharedMember: Identifiable, Codable, Equatable {
  let id: UUID
  var name: String
  var permission: String

  init(id: UUID = UUID(), name: String, permission: String = "Puede editar") {
    self.id = id
    self.name = name
    self.permission = permission
  }
}

final class ShoppingStore: ObservableObject {
  @Published var lists: [ShoppingList] = [] { didSet { save() } }
  @Published var activeListID: UUID? { didSet { save() } }
  @Published var products: [Product] = [] { didSet { save() } }
  @Published var presets: [PresetList] = [] { didSet { save() } }
  @Published var members: [SharedMember] = [] { didSet { save() } }
  @Published var canEditSharedList = true { didSet { save() } }

  private var isLoading = true
  private let listsKey = "shopping.lists.v2"
  private let activeListKey = "shopping.activeList.v2"
  private let legacyItemsKey = "shopping.items.v1"
  private let productsKey = "shopping.products.v1"
  private let presetsKey = "shopping.presets.v1"
  private let membersKey = "shopping.members.v1"
  private let editKey = "shopping.canEdit.v1"

  init() {
    load()
    isLoading = false
  }

  var activeList: ShoppingList {
    lists.first(where: { $0.id == activeListID }) ?? lists.first ?? ShoppingList(name: "Lista de la compra")
  }

  var items: [ShoppingItem] { activeList.items }
  var pendingItems: [ShoppingItem] { items.filter { !$0.checked } }
  var doneItems: [ShoppingItem] { items.filter { $0.checked } }

  var shareText: String {
    let lines = items.map { "- \($0.product.name): \($0.quantity) \($0.product.unit)\($0.checked ? " (comprado)" : "")" }
    return "\(activeList.name)\n" + lines.joined(separator: "\n")
  }

  private var activeIndex: Int? {
    lists.firstIndex { $0.id == activeListID } ?? lists.indices.first
  }

  func add(product: Product, quantity: Int) {
    guard let listIndex = activeIndex else { return }
    let safeQuantity = max(1, quantity)
    if let itemIndex = lists[listIndex].items.firstIndex(where: { $0.product.name == product.name && !$0.checked }) {
      lists[listIndex].items[itemIndex].quantity += safeQuantity
    } else {
      lists[listIndex].items.insert(ShoppingItem(product: product, quantity: safeQuantity), at: 0)
    }
  }

  func addCustomProduct(name: String, category: String, unit: String, emoji: String, assetName: String) {
    let cleaned = name.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !cleaned.isEmpty else { return }
    if products.contains(where: { $0.name.localizedCaseInsensitiveCompare(cleaned) == .orderedSame }) { return }
    let safeUnit = unit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "ud" : unit
    products.append(Product(name: cleaned, category: category.isEmpty ? "Otros" : category, unit: safeUnit, icon: "cart", assetName: assetName, emoji: emoji, tint: products.count % 6))
  }

  func toggle(_ item: ShoppingItem) {
    guard let listIndex = activeIndex, let itemIndex = lists[listIndex].items.firstIndex(where: { $0.id == item.id }) else { return }
    lists[listIndex].items[itemIndex].checked.toggle()
  }

  func increment(_ item: ShoppingItem) {
    guard let listIndex = activeIndex, let itemIndex = lists[listIndex].items.firstIndex(where: { $0.id == item.id }) else { return }
    lists[listIndex].items[itemIndex].quantity += 1
  }

  func decrement(_ item: ShoppingItem) {
    guard let listIndex = activeIndex, let itemIndex = lists[listIndex].items.firstIndex(where: { $0.id == item.id }) else { return }
    lists[listIndex].items[itemIndex].quantity = max(1, lists[listIndex].items[itemIndex].quantity - 1)
  }

  func delete(_ item: ShoppingItem) {
    guard let listIndex = activeIndex else { return }
    lists[listIndex].items.removeAll { $0.id == item.id }
  }

  func clearChecked() {
    guard let listIndex = activeIndex else { return }
    lists[listIndex].items.removeAll { $0.checked }
  }

  func createList(name: String) {
    let cleaned = name.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !cleaned.isEmpty else { return }
    let list = ShoppingList(name: cleaned)
    lists.append(list)
    activeListID = list.id
  }

  func selectList(_ list: ShoppingList) {
    activeListID = list.id
  }

  func deleteList(_ list: ShoppingList) {
    guard lists.count > 1 else { return }
    lists.removeAll { $0.id == list.id }
    if activeListID == list.id {
      activeListID = lists.first?.id
    }
  }

  func usePreset(_ preset: PresetList) {
    for name in preset.productNames {
      if let product = products.first(where: { $0.name == name }) {
        add(product: product, quantity: 1)
      }
    }
  }

  func addPreset(name: String) {
    let cleaned = name.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !cleaned.isEmpty else { return }
    let names = items.map { $0.product.name }
    presets.append(PresetList(name: cleaned, icon: "star", assetName: "preset_weekly", productNames: names))
  }

  func addMember(_ name: String) {
    let cleaned = name.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !cleaned.isEmpty else { return }
    members.append(SharedMember(name: cleaned))
  }

  func deleteMember(_ member: SharedMember) {
    members.removeAll { $0.id == member.id }
  }

  private func load() {
    products = decode([Product].self, key: productsKey) ?? Self.defaultProducts
    if let decodedLists = decode([ShoppingList].self, key: listsKey), !decodedLists.isEmpty {
      lists = decodedLists
    } else {
      let legacyItems = decode([ShoppingItem].self, key: legacyItemsKey) ?? Self.defaultItems(from: products)
      lists = [ShoppingList(name: "Lista de la compra", items: legacyItems)]
    }
    if let rawActive = UserDefaults.standard.string(forKey: activeListKey), let id = UUID(uuidString: rawActive), lists.contains(where: { $0.id == id }) {
      activeListID = id
    } else {
      activeListID = lists.first?.id
    }
    presets = decode([PresetList].self, key: presetsKey) ?? Self.defaultPresets
    members = decode([SharedMember].self, key: membersKey) ?? [SharedMember(name: "Yo"), SharedMember(name: "Casa")]
    canEditSharedList = UserDefaults.standard.object(forKey: editKey) as? Bool ?? true
  }

  private func save() {
    guard !isLoading else { return }
    encode(products, key: productsKey)
    encode(lists, key: listsKey)
    if let activeListID {
      UserDefaults.standard.set(activeListID.uuidString, forKey: activeListKey)
    }
    encode(presets, key: presetsKey)
    encode(members, key: membersKey)
    UserDefaults.standard.set(canEditSharedList, forKey: editKey)
  }

  private func encode<T: Encodable>(_ value: T, key: String) {
    if let data = try? JSONEncoder().encode(value) {
      UserDefaults.standard.set(data, forKey: key)
    }
  }

  private func decode<T: Decodable>(_ type: T.Type, key: String) -> T? {
    guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
    return try? JSONDecoder().decode(type, from: data)
  }

  static let defaultProducts: [Product] = [
    Product(name: "Leche", category: "Lacteos", unit: "l", icon: "drop", assetName: "product_milk", tint: 2),
    Product(name: "Pan", category: "Panaderia", unit: "ud", icon: "baguette", assetName: "product_bread", tint: 1),
    Product(name: "Huevos", category: "Lacteos", unit: "uds", icon: "circle.grid.cross", assetName: "product_eggs", tint: 3),
    Product(name: "Tomates", category: "Frescos", unit: "g", icon: "circle.fill", assetName: "product_tomato", tint: 4),
    Product(name: "Platanos", category: "Fruta", unit: "kg", icon: "leaf", assetName: "product_banana", tint: 5),
    Product(name: "Manzanas", category: "Fruta", unit: "kg", icon: "apple.logo", assetName: "product_apple", tint: 4),
    Product(name: "Detergente", category: "Limpieza", unit: "ud", icon: "bubbles.and.sparkles", assetName: "product_detergent", tint: 2),
    Product(name: "Papel higienico", category: "Limpieza", unit: "uds", icon: "square.stack.3d.up", assetName: "product_paper", tint: 0),
    Product(name: "Aceite de oliva", category: "Despensa", unit: "ud", icon: "drop.fill", assetName: "product_oil", tint: 1)
  ]

  static func defaultItems(from products: [Product]) -> [ShoppingItem] {
    ["Pan", "Leche", "Huevos", "Tomates"].compactMap { name in
      products.first(where: { $0.name == name }).map { ShoppingItem(product: $0, quantity: name == "Huevos" ? 1 : 2) }
    }
  }

  static let defaultPresets: [PresetList] = [
    PresetList(name: "Compra semanal", icon: "calendar", assetName: "preset_weekly", productNames: ["Pan", "Leche", "Huevos", "Tomates", "Platanos", "Detergente"]),
    PresetList(name: "Desayuno", icon: "sun.max", assetName: "preset_breakfast", productNames: ["Pan", "Leche", "Huevos"]),
    PresetList(name: "Limpieza", icon: "sparkles", assetName: "preset_cleaning", productNames: ["Detergente", "Papel higienico"]),
    PresetList(name: "Cena rapida", icon: "fork.knife", assetName: "preset_dinner", productNames: ["Aceite de oliva", "Tomates", "Pan"])
  ]
}

struct RootView: View {
  var body: some View {
    TabView {
      ListScreen().tabItem { Label("Lista", systemImage: "checklist") }
      AddScreen().tabItem { Label("Anadir", systemImage: "plus.circle") }
      PresetsScreen().tabItem { Label("Predeterminadas", systemImage: "star") }
      ShareScreen().tabItem { Label("Compartir", systemImage: "person.2") }
      MoreScreen().tabItem { Label("Mas", systemImage: "ellipsis") }
    }
    .tint(AppColors.accent)
  }
}

struct ListScreen: View {
  @EnvironmentObject private var store: ShoppingStore

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          Header(title: "Lista de la compra", subtitle: "\(store.pendingItems.count) pendientes")
          HStack(spacing: 10) {
            Chip(text: "Compartida", icon: "person.2.fill")
            Chip(text: "\(store.members.count) personas", icon: "link")
            Chip(text: store.activeList.name, icon: "list.bullet")
          }
          SummaryPanel()
          ItemSection(title: "Por comprar", items: store.pendingItems)
          if !store.doneItems.isEmpty {
            HStack {
              Text("Comprado")
                .font(.system(size: 18, weight: .bold))
              Spacer()
              Button("Limpiar") { store.clearChecked() }
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(AppColors.accent)
            }
            .foregroundStyle(AppColors.text)
            ForEach(store.doneItems) { item in
              ItemRow(item: item)
            }
          }
        }
        .padding(20)
      }
      .background(AppColors.background.ignoresSafeArea())
    }
  }
}

struct AddScreen: View {
  @EnvironmentObject private var store: ShoppingStore
  @State private var query = ""
  @State private var quantity = 1
  @State private var customName = ""
  @State private var customCategory = "Otros"
  @State private var customUnit = "ud"
  @State private var customEmoji = ""
  @State private var customAsset = "product_default"

  private var filtered: [Product] {
    store.products.filter { product in
      query.isEmpty || product.name.localizedCaseInsensitiveContains(query) || product.category.localizedCaseInsensitiveContains(query)
    }
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          Header(title: "Anadir productos", subtitle: "Elige del catalogo y ajusta la cantidad.")
          TextField("Buscar producto", text: $query)
            .textFieldStyle(AppTextFieldStyle())
          QuantityControl(quantity: $quantity)
          LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(filtered) { product in
              ProductCard(product: product, quantity: quantity)
            }
          }
          Panel {
            Text("Crear producto")
              .font(.system(size: 18, weight: .bold))
              .foregroundStyle(AppColors.text)
            TextField("Nombre", text: $customName)
              .textFieldStyle(AppTextFieldStyle())
            TextField("Categoria", text: $customCategory)
              .textFieldStyle(AppTextFieldStyle())
            TextField("Unidad", text: $customUnit)
              .textFieldStyle(AppTextFieldStyle())
            TextField("Emoji opcional", text: $customEmoji)
              .textFieldStyle(AppTextFieldStyle())
            AssetPicker(selection: $customAsset)
            Button {
              store.addCustomProduct(name: customName, category: customCategory, unit: customUnit, emoji: customEmoji, assetName: customAsset)
              customName = ""
              customEmoji = ""
            } label: {
              Label("Guardar producto", systemImage: "plus")
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
          }
        }
        .padding(20)
      }
      .background(AppColors.background.ignoresSafeArea())
    }
  }
}

struct PresetsScreen: View {
  @EnvironmentObject private var store: ShoppingStore
  @State private var newPresetName = ""

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          Header(title: "Listas base", subtitle: "Plantillas personales para repetir compras.")
          Panel {
            Text("Crear desde la lista actual")
              .font(.system(size: 18, weight: .bold))
              .foregroundStyle(AppColors.text)
            TextField("Nombre de la lista", text: $newPresetName)
              .textFieldStyle(AppTextFieldStyle())
            Button {
              store.addPreset(name: newPresetName)
              newPresetName = ""
            } label: {
              Label("Guardar predeterminada", systemImage: "plus")
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(store.items.isEmpty)
          }
          ForEach(store.presets) { preset in
            PresetCard(preset: preset)
          }
        }
        .padding(20)
      }
      .background(AppColors.background.ignoresSafeArea())
    }
  }
}

struct ShareScreen: View {
  @EnvironmentObject private var store: ShoppingStore
  @State private var memberName = ""

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          Header(title: "Compartida", subtitle: "Gestiona personas y envia la lista.")
          Panel {
            HStack {
              ResourceIcon(name: "app_group", size: 48)
              VStack(alignment: .leading, spacing: 3) {
                Text(store.activeList.name)
                  .font(.system(size: 18, weight: .bold))
                  .foregroundStyle(AppColors.text)
                Text("\(store.members.count) personas")
                  .font(.system(size: 13, weight: .medium))
                  .foregroundStyle(AppColors.muted)
              }
              Spacer()
              ShareLink(item: store.shareText) {
                Label("Enviar", systemImage: "square.and.arrow.up")
              }
              .font(.system(size: 14, weight: .bold))
              .foregroundStyle(AppColors.accent)
            }
            Toggle("Permitir edicion", isOn: $store.canEditSharedList)
              .tint(AppColors.accent)
              .foregroundStyle(AppColors.text)
            TextField("Invitar", text: $memberName)
              .textFieldStyle(AppTextFieldStyle())
            Button {
              store.addMember(memberName)
              memberName = ""
            } label: {
              Label("Anadir persona", systemImage: "person.badge.plus")
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
          }
          ForEach(store.members) { member in
            HStack(spacing: 12) {
              Text(initials(member.name))
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(AppColors.accent, in: RoundedRectangle(cornerRadius: 8))
              VStack(alignment: .leading, spacing: 3) {
                Text(member.name)
                  .font(.system(size: 16, weight: .bold))
                  .foregroundStyle(AppColors.text)
                Text(member.permission)
                  .font(.system(size: 13, weight: .medium))
                  .foregroundStyle(AppColors.muted)
              }
              Spacer()
              Button(role: .destructive) {
                store.deleteMember(member)
              } label: {
                Image(systemName: "trash")
              }
            }
            .padding(12)
            .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 8))
          }
          Panel {
            Text("Vista previa")
              .font(.system(size: 18, weight: .bold))
              .foregroundStyle(AppColors.text)
            Text(store.shareText)
              .font(.system(size: 14, weight: .medium))
              .foregroundStyle(AppColors.muted)
          }
        }
        .padding(20)
      }
      .background(AppColors.background.ignoresSafeArea())
    }
  }

  private func initials(_ value: String) -> String {
    value.split(separator: " ").prefix(2).compactMap { $0.first }.map(String.init).joined().uppercased()
  }
}

struct MoreScreen: View {
  @EnvironmentObject private var store: ShoppingStore
  @State private var listName = ""

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          Header(title: "Mas", subtitle: "Crea listas y cambia la lista activa.")
          Panel {
            Text("Nueva lista")
              .font(.system(size: 18, weight: .bold))
              .foregroundStyle(AppColors.text)
            TextField("Nombre", text: $listName)
              .textFieldStyle(AppTextFieldStyle())
            Button {
              store.createList(name: listName)
              listName = ""
            } label: {
              Label("Crear lista", systemImage: "plus")
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
          }
          ForEach(store.lists) { list in
            HStack(spacing: 12) {
              Image(systemName: store.activeListID == list.id ? "checkmark.circle.fill" : "list.bullet")
                .foregroundStyle(store.activeListID == list.id ? AppColors.accent : AppColors.muted)
                .font(.system(size: 22, weight: .bold))
              VStack(alignment: .leading, spacing: 3) {
                Text(list.name)
                  .font(.system(size: 17, weight: .bold))
                  .foregroundStyle(AppColors.text)
                Text("\(list.items.count) productos")
                  .font(.system(size: 13, weight: .medium))
                  .foregroundStyle(AppColors.muted)
              }
              Spacer()
              Button("Usar") { store.selectList(list) }
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(AppColors.accent)
              Button(role: .destructive) { store.deleteList(list) } label: {
                Image(systemName: "trash")
              }
              .disabled(store.lists.count <= 1)
            }
            .padding(12)
            .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 8))
          }
        }
        .padding(20)
      }
      .background(AppColors.background.ignoresSafeArea())
    }
  }
}

struct SummaryPanel: View {
  @EnvironmentObject private var store: ShoppingStore

  var body: some View {
    HStack(spacing: 12) {
      Metric(title: "Total", value: "\(store.items.count)")
      Metric(title: "Pendiente", value: "\(store.pendingItems.count)")
      Metric(title: "Hecho", value: "\(store.doneItems.count)")
    }
  }
}

struct Metric: View {
  let title: String
  let value: String

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(title)
        .font(.system(size: 12, weight: .bold))
        .foregroundStyle(AppColors.muted)
      Text(value)
        .font(.system(size: 22, weight: .bold))
        .foregroundStyle(AppColors.text)
    }
    .padding(12)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 8))
  }
}

struct ItemSection: View {
  let title: String
  let items: [ShoppingItem]

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(title)
        .font(.system(size: 18, weight: .bold))
        .foregroundStyle(AppColors.text)
      if items.isEmpty {
        EmptyState(text: "No hay productos pendientes.")
      } else {
        ForEach(items) { item in
          ItemRow(item: item)
        }
      }
    }
  }
}

struct ItemRow: View {
  @EnvironmentObject private var store: ShoppingStore
  let item: ShoppingItem

  var body: some View {
    HStack(spacing: 12) {
      Button { store.toggle(item) } label: {
        Image(systemName: item.checked ? "checkmark.circle.fill" : "circle")
          .font(.system(size: 22, weight: .semibold))
          .foregroundStyle(item.checked ? AppColors.accent : AppColors.muted)
      }
      ProductIcon(product: item.product, size: 42)
      VStack(alignment: .leading, spacing: 3) {
        Text(item.product.name)
          .font(.system(size: 16, weight: .bold))
          .foregroundStyle(item.checked ? AppColors.muted : AppColors.text)
          .strikethrough(item.checked)
        Text(item.product.category)
          .font(.system(size: 13, weight: .medium))
          .foregroundStyle(AppColors.muted)
      }
      Spacer()
      HStack(spacing: 8) {
        Button { store.decrement(item) } label: { Image(systemName: "minus") }
        Text("\(item.quantity) \(item.product.unit)")
          .font(.system(size: 13, weight: .bold))
          .frame(minWidth: 46)
        Button { store.increment(item) } label: { Image(systemName: "plus") }
      }
      .foregroundStyle(AppColors.accent)
      Button(role: .destructive) { store.delete(item) } label: {
        Image(systemName: "trash")
          .foregroundStyle(AppColors.danger)
      }
    }
    .buttonStyle(.plain)
    .padding(12)
    .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 8))
    .swipeActions(edge: .trailing) {
      Button(role: .destructive) { store.delete(item) } label: {
        Label("Borrar", systemImage: "trash")
      }
    }
  }
}

struct ProductCard: View {
  @EnvironmentObject private var store: ShoppingStore
  let product: Product
  let quantity: Int

  var body: some View {
    Button {
      store.add(product: product, quantity: quantity)
    } label: {
      VStack(alignment: .leading, spacing: 10) {
        ProductIcon(product: product, size: 46)
        Text(product.name)
          .font(.system(size: 16, weight: .bold))
          .foregroundStyle(AppColors.text)
          .lineLimit(1)
        Text(product.category)
          .font(.system(size: 12, weight: .bold))
          .foregroundStyle(AppColors.muted)
        Label("Anadir", systemImage: "plus.circle.fill")
          .font(.system(size: 13, weight: .bold))
          .foregroundStyle(AppColors.accent)
      }
      .padding(14)
      .frame(maxWidth: .infinity, minHeight: 142, alignment: .leading)
      .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 8))
    }
    .buttonStyle(.plain)
  }
}

struct PresetCard: View {
  @EnvironmentObject private var store: ShoppingStore
  let preset: PresetList

  private var products: [Product] {
    preset.productNames.compactMap { name in store.products.first(where: { $0.name == name }) }
  }

  var body: some View {
    Panel {
      HStack(alignment: .top, spacing: 12) {
        ResourceIcon(name: preset.assetName, size: 64)
        VStack(alignment: .leading, spacing: 6) {
          Text(preset.name)
            .font(.system(size: 19, weight: .bold))
            .foregroundStyle(AppColors.text)
          Text("\(preset.productNames.count) productos")
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(AppColors.muted)
          HStack(spacing: -6) {
            ForEach(products.prefix(5)) { product in
              ProductIcon(product: product, size: 32)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppColors.surface, lineWidth: 2))
            }
          }
        }
        Spacer()
        Button("Usar") {
          store.usePreset(preset)
        }
        .font(.system(size: 14, weight: .bold))
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .frame(height: 38)
        .background(AppColors.accent, in: RoundedRectangle(cornerRadius: 8))
      }
    }
  }
}

struct QuantityControl: View {
  @Binding var quantity: Int

  var body: some View {
    HStack {
      Text("Cantidad")
        .font(.system(size: 15, weight: .bold))
        .foregroundStyle(AppColors.text)
      Spacer()
      Button { quantity = max(1, quantity - 1) } label: { Image(systemName: "minus") }
      Text("\(quantity)")
        .font(.system(size: 18, weight: .bold))
        .foregroundStyle(AppColors.text)
        .frame(width: 44)
      Button { quantity += 1 } label: { Image(systemName: "plus") }
    }
    .buttonStyle(.bordered)
    .tint(AppColors.accent)
    .padding(14)
    .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 8))
  }
}

struct ProductIcon: View {
  let product: Product
  let size: CGFloat

  var body: some View {
    if !product.emoji.isEmpty {
      Text(String(product.emoji.prefix(2)))
        .font(.system(size: size * 0.46, weight: .bold))
        .frame(width: size, height: size)
        .background(iconColor(product.tint).opacity(0.18), in: RoundedRectangle(cornerRadius: 8))
    } else {
      ResourceIcon(name: product.assetName, size: size)
    }
  }
}

struct ResourceIcon: View {
  let name: String
  let size: CGFloat

  var body: some View {
    Group {
      if let image = UIImage(named: name) {
        Image(uiImage: image)
          .resizable()
      } else if let url = Bundle.main.url(forResource: name, withExtension: "png"),
                let image = UIImage(contentsOfFile: url.path) {
        Image(uiImage: image)
          .resizable()
      } else {
        Image(systemName: "cart")
          .resizable()
          .scaledToFit()
          .padding(size * 0.28)
          .foregroundStyle(AppColors.accent)
          .background(AppColors.accent.opacity(0.16))
      }
    }
    .scaledToFit()
    .frame(width: size, height: size)
    .clipShape(RoundedRectangle(cornerRadius: 8))
  }
}

struct AssetPicker: View {
  @Binding var selection: String

  private let assets = [
    "product_default", "product_milk", "product_bread", "product_eggs", "product_tomato", "product_banana", "product_apple", "product_detergent", "product_paper", "product_oil",
    "product_cheese", "product_yogurt", "product_butter", "product_chicken", "product_fish", "product_meat", "product_ham", "product_frozen",
    "product_rice", "product_pasta", "product_flour", "product_sugar", "product_salt", "product_coffee", "product_tea", "product_cereal",
    "product_water", "product_juice", "product_soda", "product_wine", "product_soap", "product_shampoo", "product_toothpaste", "product_toilet_cleaner",
    "product_trash_bags", "product_sponge", "product_dish_soap", "product_softener", "product_diapers", "product_pet_food", "product_baby_food", "product_medicine"
  ]

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Imagen")
        .font(.system(size: 13, weight: .bold))
        .foregroundStyle(AppColors.muted)
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 10) {
          ForEach(assets, id: \.self) { asset in
            Button {
              selection = asset
            } label: {
              ResourceIcon(name: asset, size: 44)
                .overlay(
                  RoundedRectangle(cornerRadius: 8)
                    .stroke(selection == asset ? AppColors.accent : Color.clear, lineWidth: 3)
                )
            }
            .buttonStyle(.plain)
          }
        }
      }
    }
  }
}

struct Header: View {
  let title: String
  let subtitle: String

  var body: some View {
    VStack(alignment: .leading, spacing: 5) {
      Text(title)
        .font(.system(size: 30, weight: .bold))
        .foregroundStyle(AppColors.text)
      Text(subtitle)
        .font(.system(size: 15, weight: .medium))
        .foregroundStyle(AppColors.muted)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

struct Chip: View {
  let text: String
  let icon: String

  var body: some View {
    Label(text, systemImage: icon)
      .font(.system(size: 13, weight: .bold))
      .foregroundStyle(AppColors.accent)
      .padding(.horizontal, 12)
      .frame(height: 34)
      .background(AppColors.accent.opacity(0.14), in: Capsule())
  }
}

struct Panel<Content: View>: View {
  let content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      content
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 8))
  }
}

struct EmptyState: View {
  let text: String

  var body: some View {
    Text(text)
      .font(.system(size: 15, weight: .medium))
      .foregroundStyle(AppColors.muted)
      .frame(maxWidth: .infinity, minHeight: 86)
      .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 8))
  }
}

struct AppTextFieldStyle: TextFieldStyle {
  func _body(configuration: TextField<Self._Label>) -> some View {
    configuration
      .font(.system(size: 16, weight: .semibold))
      .foregroundStyle(AppColors.text)
      .padding(13)
      .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 8))
  }
}

struct PrimaryButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.system(size: 15, weight: .bold))
      .foregroundStyle(.white)
      .frame(minHeight: 46)
      .background(AppColors.accent, in: RoundedRectangle(cornerRadius: 8))
      .opacity(configuration.isPressed ? 0.72 : 1)
  }
}

func iconColor(_ index: Int) -> Color {
  let colors = [
    Color(red: 0.55, green: 0.77, blue: 0.64),
    Color(red: 0.93, green: 0.62, blue: 0.28),
    Color(red: 0.35, green: 0.68, blue: 0.92),
    Color(red: 0.94, green: 0.78, blue: 0.35),
    Color(red: 0.91, green: 0.36, blue: 0.31),
    Color(red: 0.62, green: 0.78, blue: 0.38)
  ]
  return colors[index % colors.count]
}

enum AppColors {
  static let background = Color(red: 0.02, green: 0.03, blue: 0.02)
  static let surface = Color(red: 0.10, green: 0.12, blue: 0.10)
  static let text = Color(red: 0.94, green: 0.96, blue: 0.93)
  static let muted = Color(red: 0.61, green: 0.66, blue: 0.62)
  static let accent = Color(red: 0.14, green: 0.76, blue: 0.42)
  static let danger = Color(red: 0.92, green: 0.30, blue: 0.27)
}
