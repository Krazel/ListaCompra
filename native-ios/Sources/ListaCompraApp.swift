import SwiftUI
import UIKit
import PhotosUI

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
  var customImageData: Data?
  var tint: Int

  init(id: UUID = UUID(), name: String, category: String, unit: String, icon: String, assetName: String = "product_default", emoji: String = "", customImageData: Data? = nil, tint: Int) {
    self.id = id
    self.name = name
    self.category = category
    self.unit = unit
    self.icon = icon
    self.assetName = assetName
    self.emoji = emoji
    self.customImageData = customImageData
    self.tint = tint
  }

  enum CodingKeys: String, CodingKey {
    case id, name, category, unit, icon, assetName, emoji, customImageData, tint
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
    customImageData = try values.decodeIfPresent(Data.self, forKey: .customImageData)
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
    let lines = items.map { "- \($0.product.name): \($0.quantity)\($0.checked ? " (comprado)" : "")" }
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

  @discardableResult
  func addCustomProduct(name: String, category: String, unit: String, emoji: String, assetName: String, customImageData: Data? = nil) -> Product? {
    let cleaned = name.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !cleaned.isEmpty else { return nil }
    if let existing = products.first(where: { $0.name.localizedCaseInsensitiveCompare(cleaned) == .orderedSame }) { return existing }
    let safeUnit = unit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "ud" : unit
    let product = Product(name: cleaned, category: category.isEmpty ? "Otros" : category, unit: safeUnit, icon: "cart", assetName: assetName, emoji: emoji, customImageData: customImageData, tint: products.count % 6)
    products.append(product)
    return product
  }

  func updateProduct(_ product: Product, name: String, category: String, unit: String, emoji: String, assetName: String, customImageData: Data? = nil) {
    let cleaned = name.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !cleaned.isEmpty, let index = products.firstIndex(where: { $0.id == product.id }) else { return }
    let updated = Product(
      id: product.id,
      name: cleaned,
      category: category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Otros" : category,
      unit: unit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "ud" : unit,
      icon: product.icon,
      assetName: assetName,
      emoji: emoji,
      customImageData: customImageData,
      tint: product.tint
    )
    products[index] = updated
    for listIndex in lists.indices {
      for itemIndex in lists[listIndex].items.indices where lists[listIndex].items[itemIndex].product.id == product.id || lists[listIndex].items[itemIndex].product.name == product.name {
        lists[listIndex].items[itemIndex].product = updated
      }
    }
    for presetIndex in presets.indices {
      presets[presetIndex].productNames = presets[presetIndex].productNames.map { $0 == product.name ? updated.name : $0 }
    }
  }

  func deleteProduct(_ product: Product) {
    products.removeAll { $0.id == product.id }
    for listIndex in lists.indices {
      lists[listIndex].items.removeAll { $0.product.id == product.id || $0.product.name == product.name }
    }
    for presetIndex in presets.indices {
      presets[presetIndex].productNames.removeAll { $0 == product.name }
    }
  }

  func upsertProduct(name: String, category: String = "Importados", unit: String = "ud") -> Product {
    let cleaned = name.trimmingCharacters(in: .whitespacesAndNewlines)
    if let existing = products.first(where: { $0.name.localizedCaseInsensitiveCompare(cleaned) == .orderedSame }) {
      return existing
    }
    let product = Product(name: cleaned, category: category, unit: unit, icon: "cart", assetName: Product.defaultAsset(for: cleaned), tint: products.count % 6)
    products.append(product)
    return product
  }

  func parsedNames(from text: String) -> [String] {
    var seen: Set<String> = []
    return text
      .components(separatedBy: CharacterSet(charactersIn: ",\n;"))
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty }
      .filter { seen.insert($0.lowercased()).inserted }
  }

  @discardableResult
  func importKnownProducts(from text: String) -> [String] {
    var missing: [String] = []
    for name in parsedNames(from: text) {
      if let product = products.first(where: { $0.name.localizedCaseInsensitiveCompare(name) == .orderedSame }) {
        add(product: product, quantity: 1)
      } else {
        missing.append(name)
      }
    }
    return missing
  }

  var categories: [String] {
    Array(Set(products.map { $0.category })).sorted()
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

  func updatePreset(_ preset: PresetList, name: String, assetName: String? = nil, productNames: [String]) {
    guard let index = presets.firstIndex(where: { $0.id == preset.id }) else { return }
    presets[index].name = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? preset.name : name
    if let assetName {
      presets[index].assetName = assetName
    }
    presets[index].productNames = productNames
  }

  func deletePreset(_ preset: PresetList) {
    presets.removeAll { $0.id == preset.id }
  }

  func presetContains(_ preset: PresetList, product: Product) -> Bool {
    preset.productNames.contains(product.name)
  }

  func setProduct(_ product: Product, in preset: PresetList, enabled: Bool) {
    guard let index = presets.firstIndex(where: { $0.id == preset.id }) else { return }
    let exists = presets[index].productNames.contains(product.name)
    if enabled, !exists {
      presets[index].productNames.append(product.name)
    } else if !enabled {
      presets[index].productNames.removeAll { $0 == product.name }
    }
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
    if lists.count == 1, lists[0].name == "Lista de la compra" {
      lists.append(ShoppingList(name: "Casa"))
      lists.append(ShoppingList(name: "Semana"))
      lists.append(ShoppingList(name: "Fiesta"))
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
    Product(name: "Aceite de oliva", category: "Despensa", unit: "ud", icon: "drop.fill", assetName: "product_oil", tint: 1),
    Product(name: "Arroz", category: "Despensa", unit: "kg", icon: "shippingbox", assetName: "product_rice", tint: 1),
    Product(name: "Pasta", category: "Despensa", unit: "paq", icon: "takeoutbag.and.cup.and.straw", assetName: "product_pasta", tint: 1),
    Product(name: "Cafe", category: "Desayuno", unit: "paq", icon: "cup.and.saucer", assetName: "product_coffee", tint: 1),
    Product(name: "Congelados", category: "Congelador", unit: "bol", icon: "snowflake", assetName: "product_frozen", tint: 2),
    Product(name: "Queso", category: "Lacteos", unit: "ud", icon: "triangle", assetName: "product_cheese", tint: 3),
    Product(name: "Agua", category: "Bebidas", unit: "l", icon: "waterbottle", assetName: "product_water", tint: 2)
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
    }
    .tint(AppColors.accent)
  }
}

struct ListScreen: View {
  @EnvironmentObject private var store: ShoppingStore

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 12) {
          ListTitleBar()
          ListSwitcher()
          SummaryPanel()
          MainQuickAddBar()
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
  @State private var showingCreateProduct = false

  private var filtered: [Product] {
    store.products.filter { product in
      query.isEmpty || product.name.localizedCaseInsensitiveContains(query) || product.category.localizedCaseInsensitiveContains(query)
    }
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          HStack(alignment: .top) {
            Header(title: "Anadir productos", subtitle: "Elige del catalogo y ajusta la cantidad.")
            Spacer()
            Button { showingCreateProduct = true } label: {
              Image(systemName: "plus")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(AppColors.accent, in: RoundedRectangle(cornerRadius: 8))
            }
          }
          TextField("Buscar producto", text: $query)
            .textFieldStyle(AppTextFieldStyle())
          QuantityControl(quantity: $quantity)
          LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(filtered) { product in
              ProductCard(product: product, quantity: quantity)
            }
          }
        }
        .padding(20)
      }
      .scrollDismissesKeyboard(.interactively)
      .background(AppColors.background.ignoresSafeArea())
      .sheet(isPresented: $showingCreateProduct) {
        ProductEditorSheet(mode: .create())
          .environmentObject(store)
      }
    }
  }
}

struct PresetsScreen: View {
  @EnvironmentObject private var store: ShoppingStore
  @State private var newPresetName = ""
  @State private var editingPreset: PresetList?

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
            Button {
              editingPreset = preset
            } label: {
              PresetCard(preset: preset)
            }
            .buttonStyle(.plain)
          }
        }
        .padding(20)
      }
      .background(AppColors.background.ignoresSafeArea())
      .sheet(item: $editingPreset) { preset in
        PresetEditorSheet(preset: preset)
          .environmentObject(store)
      }
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
    HStack(spacing: 8) {
      Metric(title: "Total", value: "\(store.items.count)")
      Metric(title: "Pendiente", value: "\(store.pendingItems.count)")
      Metric(title: "Hecho", value: "\(store.doneItems.count)")
    }
  }
}

struct ListTitleBar: View {
  @EnvironmentObject private var store: ShoppingStore
  @State private var showingInfo = false

  var body: some View {
    HStack(alignment: .center, spacing: 12) {
      VStack(alignment: .leading, spacing: 4) {
        Text(store.activeList.name)
          .font(.system(size: 30, weight: .bold))
          .foregroundStyle(AppColors.text)
          .lineLimit(1)
        Text("Lista de la compra")
          .font(.system(size: 14, weight: .medium))
          .foregroundStyle(AppColors.muted)
      }
      Spacer()
      Menu {
        Button("Informacion de la lista", systemImage: "info.circle") {
          showingInfo = true
        }
        Button("Compartir como texto", systemImage: "square.and.arrow.up") {
          UIPasteboard.general.string = store.shareText
        }
        if store.lists.count > 1 {
          Button("Eliminar lista", systemImage: "trash", role: .destructive) {
            store.deleteList(store.activeList)
          }
        }
      } label: {
        Image(systemName: "ellipsis")
          .font(.system(size: 20, weight: .bold))
          .foregroundStyle(AppColors.text)
          .frame(width: 42, height: 42)
          .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 8))
      }
    }
    .sheet(isPresented: $showingInfo) {
      ListInfoSheet()
        .environmentObject(store)
    }
  }
}

struct ListSwitcher: View {
  @EnvironmentObject private var store: ShoppingStore
  @State private var newListName = ""
  @State private var creating = false

  var body: some View {
    HStack(spacing: 8) {
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 8) {
          ForEach(store.lists) { list in
            Button {
              store.selectList(list)
            } label: {
              Text(list.name)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(store.activeListID == list.id ? .white : AppColors.accent)
                .padding(.horizontal, 12)
                .frame(height: 34)
                .background(store.activeListID == list.id ? AppColors.accent : AppColors.accent.opacity(0.14), in: Capsule())
            }
            .buttonStyle(.plain)
          }
        }
      }
      Button { creating = true } label: {
        Image(systemName: "plus")
          .font(.system(size: 15, weight: .bold))
          .foregroundStyle(AppColors.accent)
          .frame(width: 34, height: 34)
          .background(AppColors.accent.opacity(0.14), in: Circle())
      }
    }
    .sheet(isPresented: $creating) {
      NavigationStack {
        VStack(alignment: .leading, spacing: 16) {
          Header(title: "Nueva lista", subtitle: "Crea una lista de compra.")
          TextField("Nombre", text: $newListName)
            .textFieldStyle(AppTextFieldStyle())
          Button {
            store.createList(name: newListName)
            newListName = ""
            creating = false
          } label: {
            Label("Crear lista", systemImage: "plus")
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(PrimaryButtonStyle())
          Spacer()
        }
        .padding(20)
        .background(AppColors.background.ignoresSafeArea())
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button("Cancelar") { creating = false }
          }
        }
      }
    }
  }
}

struct MainQuickAddBar: View {
  @EnvironmentObject private var store: ShoppingStore
  @FocusState private var focused: Bool
  @State private var query = ""
  @State private var showingBulkImport = false
  @State private var creatingProduct = false

  private var matches: [Product] {
    guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return [] }
    return store.products
      .filter { $0.name.localizedCaseInsensitiveContains(query) || $0.category.localizedCaseInsensitiveContains(query) }
      .prefix(4)
      .map { $0 }
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack(spacing: 8) {
        Image(systemName: "magnifyingglass")
          .foregroundStyle(AppColors.muted)
        TextField("Anadir o buscar producto", text: $query)
          .font(.system(size: 15, weight: .semibold))
          .foregroundStyle(AppColors.text)
          .focused($focused)
          .submitLabel(.done)
          .onSubmit(addBestMatch)
        Button { showingBulkImport = true } label: {
          Image(systemName: "doc.on.clipboard")
            .frame(width: 34, height: 34)
        }
        Button {
          creatingProduct = true
        } label: {
          Image(systemName: "plus")
            .frame(width: 34, height: 34)
        }
      }
      .buttonStyle(.plain)
      .foregroundStyle(AppColors.accent)
      .padding(10)
      .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 8))

      if !matches.isEmpty {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 8) {
            ForEach(matches) { product in
              Button {
                store.add(product: product, quantity: 1)
                query = ""
                focused = false
              } label: {
                HStack(spacing: 6) {
                  ProductIcon(product: product, size: 28)
                  Text(product.name)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(AppColors.text)
                }
                .padding(.horizontal, 10)
                .frame(height: 38)
                .background(AppColors.surface, in: Capsule())
              }
              .buttonStyle(.plain)
            }
          }
        }
      }
    }
    .sheet(isPresented: $showingBulkImport) {
      BulkImportSheet()
        .environmentObject(store)
    }
    .sheet(isPresented: $creatingProduct) {
      ProductEditorSheet(mode: .create(prefill: query))
        .environmentObject(store)
    }
  }

  private func addBestMatch() {
    if let product = matches.first {
      store.add(product: product, quantity: 1)
      query = ""
    } else {
      creatingProduct = true
    }
    focused = false
  }
}

struct ListInfoSheet: View {
  @EnvironmentObject private var store: ShoppingStore
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          Header(title: store.activeList.name, subtitle: "Informacion de la lista")
          Panel {
            Text("Esta version permite compartir la lista como texto. No sincroniza en tiempo real entre moviles todavia.")
              .font(.system(size: 14, weight: .medium))
              .foregroundStyle(AppColors.muted)
            Text("Productos: \(store.items.count)")
              .foregroundStyle(AppColors.text)
            Text("Pendientes: \(store.pendingItems.count)")
              .foregroundStyle(AppColors.text)
          }
        }
        .padding(20)
      }
      .background(AppColors.background.ignoresSafeArea())
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Cerrar") { dismiss() }
        }
      }
    }
  }
}

struct BulkImportSheet: View {
  @EnvironmentObject private var store: ShoppingStore
  @Environment(\.dismiss) private var dismiss
  @FocusState private var focused: Bool
  @State private var text = ""
  @State private var missingNames: [String] = []
  @State private var creatingName: String?

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 14) {
          Header(title: "Pegar lista", subtitle: "Separa productos por coma o linea.")
          TextEditor(text: $text)
            .focused($focused)
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(AppColors.text)
            .scrollContentBackground(.hidden)
            .padding(12)
            .frame(minHeight: 190)
            .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 8))
          Button {
            missingNames = store.importKnownProducts(from: text)
            focused = false
            if missingNames.isEmpty {
              dismiss()
            }
          } label: {
            Label("Anadir productos existentes", systemImage: "plus")
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(PrimaryButtonStyle())
          if !missingNames.isEmpty {
            Panel {
              Text("No estan en el catalogo")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(AppColors.text)
              ForEach(missingNames, id: \.self) { name in
                HStack(spacing: 10) {
                  ResourceIcon(name: Product.defaultAsset(for: name), size: 40)
                  VStack(alignment: .leading, spacing: 3) {
                    Text(name)
                      .font(.system(size: 15, weight: .bold))
                      .foregroundStyle(AppColors.text)
                    Text("Configura nombre, categoria e imagen")
                      .font(.system(size: 12, weight: .medium))
                      .foregroundStyle(AppColors.muted)
                  }
                  Spacer()
                  Button("Crear") {
                    creatingName = name
                  }
                  .font(.system(size: 13, weight: .bold))
                  .foregroundStyle(.white)
                  .padding(.horizontal, 12)
                  .frame(height: 34)
                  .background(AppColors.accent, in: RoundedRectangle(cornerRadius: 8))
                }
              }
            }
          }
        }
        .padding(20)
      }
      .background(AppColors.background.ignoresSafeArea())
      .scrollDismissesKeyboard(.interactively)
      .simultaneousGesture(TapGesture().onEnded { focused = false })
      .sheet(isPresented: Binding(get: { creatingName != nil }, set: { if !$0 { creatingName = nil } })) {
        ProductEditorSheet(mode: .create(prefill: creatingName ?? "", addToList: true))
          .environmentObject(store)
      }
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancelar") { dismiss() }
        }
      }
    }
  }
}

struct CategorySelector: View {
  @EnvironmentObject private var store: ShoppingStore
  @Binding var selection: String
  @State private var customCategory = ""

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Categoria")
        .font(.system(size: 13, weight: .bold))
        .foregroundStyle(AppColors.muted)
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 8) {
          ForEach(store.categories, id: \.self) { category in
            Button {
              selection = category
            } label: {
              Text(category)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(selection == category ? .white : AppColors.accent)
                .padding(.horizontal, 12)
                .frame(height: 34)
                .background(selection == category ? AppColors.accent : AppColors.accent.opacity(0.14), in: Capsule())
            }
            .buttonStyle(.plain)
          }
        }
      }
      HStack {
        TextField("Nueva categoria", text: $customCategory)
          .textFieldStyle(AppTextFieldStyle())
        Button {
          let cleaned = customCategory.trimmingCharacters(in: .whitespacesAndNewlines)
          if !cleaned.isEmpty {
            selection = cleaned
            customCategory = ""
          }
        } label: {
          Image(systemName: "plus")
            .frame(width: 44, height: 44)
        }
        .buttonStyle(PrimaryButtonStyle())
      }
    }
  }
}

struct PresetEditorSheet: View {
  @EnvironmentObject private var store: ShoppingStore
  @Environment(\.dismiss) private var dismiss
  let preset: PresetList
  @State private var name: String
  @State private var assetName: String
  @State private var productNames: [String]
  @State private var addName = ""
  @State private var search = ""

  init(preset: PresetList) {
    self.preset = preset
    _name = State(initialValue: preset.name)
    _assetName = State(initialValue: preset.assetName)
    _productNames = State(initialValue: preset.productNames)
  }

  private var filteredProducts: [Product] {
    store.products.filter { product in
      !productNames.contains(product.name) && (search.isEmpty || product.name.localizedCaseInsensitiveContains(search) || product.category.localizedCaseInsensitiveContains(search))
    }
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          Header(title: "Editar lista base", subtitle: preset.name)
          HStack(spacing: 12) {
            ResourceIcon(name: assetName, size: 70)
            VStack(alignment: .leading, spacing: 8) {
              Text("Imagen general")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(AppColors.text)
              AssetPicker(selection: $assetName)
            }
          }
          TextField("Nombre", text: $name)
            .textFieldStyle(AppTextFieldStyle())
          Panel {
            Button {
              let current = store.items.map { $0.product.name }
              productNames = Array(Set(productNames + current)).sorted()
            } label: {
              Label("Anadir lista actual", systemImage: "text.badge.plus")
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            Text("Productos")
              .font(.system(size: 18, weight: .bold))
              .foregroundStyle(AppColors.text)
            ForEach(productNames, id: \.self) { productName in
              HStack {
                Text(productName)
                  .foregroundStyle(AppColors.text)
                Spacer()
                Button(role: .destructive) {
                  productNames.removeAll { $0 == productName }
                } label: {
                  Image(systemName: "trash")
                }
              }
            }
            TextField("Buscar producto para anadir", text: $search)
              .textFieldStyle(AppTextFieldStyle())
            ForEach(filteredProducts.prefix(8)) { product in
              HStack(spacing: 10) {
                ProductIcon(product: product, size: 34)
                VStack(alignment: .leading, spacing: 2) {
                  Text(product.name).font(.system(size: 15, weight: .bold)).foregroundStyle(AppColors.text)
                  Text(product.category).font(.system(size: 12, weight: .medium)).foregroundStyle(AppColors.muted)
                }
                Spacer()
                Button {
                  productNames.append(product.name)
                } label: {
                  Image(systemName: "plus.circle.fill")
                    .foregroundStyle(AppColors.accent)
                }
              }
            }
            if !search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !store.products.contains(where: { $0.name.localizedCaseInsensitiveCompare(search) == .orderedSame }) {
              Button {
                let product = store.upsertProduct(name: search)
                productNames.append(product.name)
                search = ""
              } label: {
                Label("Crear '\(search)'", systemImage: "plus")
                  .frame(maxWidth: .infinity)
              }
              .buttonStyle(PrimaryButtonStyle())
            }
          }
          Button(role: .destructive) {
            store.deletePreset(preset)
            dismiss()
          } label: {
            Label("Borrar lista base", systemImage: "trash")
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(PrimaryButtonStyle())
        }
        .padding(20)
      }
      .background(AppColors.background.ignoresSafeArea())
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancelar") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Guardar") {
            store.updatePreset(preset, name: name, assetName: assetName, productNames: productNames)
            dismiss()
          }
        }
      }
    }
  }
}

struct Metric: View {
  let title: String
  let value: String

  var body: some View {
    HStack(spacing: 5) {
      Text(title)
        .font(.system(size: 12, weight: .bold))
        .foregroundStyle(AppColors.muted)
      Text(value)
        .font(.system(size: 13, weight: .bold))
        .foregroundStyle(AppColors.text)
    }
    .padding(.horizontal, 10)
    .frame(height: 32)
    .background(AppColors.surface, in: Capsule())
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

enum ProductEditorMode {
  case create(prefill: String = "", addToList: Bool = false)
  case edit(Product)
}

struct ProductEditorSheet: View {
  @EnvironmentObject private var store: ShoppingStore
  @Environment(\.dismiss) private var dismiss
  @FocusState private var focused: Bool
  let mode: ProductEditorMode
  @State private var name: String
  @State private var category: String
  @State private var unit: String
  @State private var emoji: String
  @State private var assetName: String
  @State private var customImageData: Data?
  @State private var selectedPhoto: PhotosPickerItem?
  @State private var imageMode: String

  init(mode: ProductEditorMode) {
    self.mode = mode
    switch mode {
    case .create(let prefill, _):
      _name = State(initialValue: prefill)
      _category = State(initialValue: "Otros")
      _unit = State(initialValue: "ud")
      _emoji = State(initialValue: "")
      _assetName = State(initialValue: "product_default")
      _customImageData = State(initialValue: nil)
      _selectedPhoto = State(initialValue: nil)
      _imageMode = State(initialValue: "Icono")
    case .edit(let product):
      _name = State(initialValue: product.name)
      _category = State(initialValue: product.category)
      _unit = State(initialValue: product.unit)
      _emoji = State(initialValue: product.emoji)
      _assetName = State(initialValue: product.assetName)
      _customImageData = State(initialValue: product.customImageData)
      _selectedPhoto = State(initialValue: nil)
      _imageMode = State(initialValue: product.customImageData == nil ? (product.emoji.isEmpty ? "Icono" : "Emoji") : "Foto")
    }
  }

  private var title: String {
    if case .edit = mode { return "Editar producto" }
    return "Nuevo producto"
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          Header(title: title, subtitle: "Nombre, categoria e imagen.")
          HStack {
            if imageMode == "Foto", let customImageData, let image = UIImage(data: customImageData) {
              Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 74, height: 74)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else if imageMode == "Emoji", !emoji.isEmpty {
              Text(String(emoji.prefix(2)))
                .font(.system(size: 34, weight: .bold))
                .frame(width: 74, height: 74)
                .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 8))
            } else {
              ResourceIcon(name: assetName, size: 74)
            }
            VStack(alignment: .leading, spacing: 6) {
              Text(name.isEmpty ? "Producto" : name)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(AppColors.text)
              Text(category)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppColors.muted)
            }
          }
          TextField("Nombre", text: $name)
            .textFieldStyle(AppTextFieldStyle())
            .focused($focused)
          CategorySelector(selection: $category)
            .environmentObject(store)
          Picker("Imagen", selection: $imageMode) {
            Text("Icono").tag("Icono")
            Text("Emoji").tag("Emoji")
            Text("Foto").tag("Foto")
          }
          .pickerStyle(.segmented)
          if imageMode == "Emoji" {
            TextField("Emoji", text: $emoji)
              .textFieldStyle(AppTextFieldStyle())
              .focused($focused)
          } else if imageMode == "Foto" {
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
              Label(customImageData == nil ? "Elegir imagen del movil" : "Cambiar imagen del movil", systemImage: "photo.on.rectangle")
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            AssetPicker(selection: $assetName)
          } else {
            AssetPicker(selection: $assetName)
          }
          if case .edit(let product) = mode {
            Button {
              store.deleteProduct(product)
              dismiss()
            } label: {
              Label("Eliminar producto", systemImage: "trash")
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .tint(AppColors.danger)
          }
        }
        .padding(20)
      }
      .scrollDismissesKeyboard(.interactively)
      .simultaneousGesture(TapGesture().onEnded { focused = false })
      .task(id: selectedPhoto) {
        guard let selectedPhoto else { return }
        customImageData = try? await selectedPhoto.loadTransferable(type: Data.self)
      }
      .background(AppColors.background.ignoresSafeArea())
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancelar") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Guardar") {
            let savedPhoto = imageMode == "Foto" ? customImageData : nil
            let savedEmoji = imageMode == "Emoji" ? emoji : ""
            switch mode {
            case .create(_, let addToList):
              if let product = store.addCustomProduct(name: name, category: category, unit: unit, emoji: savedEmoji, assetName: assetName, customImageData: savedPhoto), addToList {
                store.add(product: product, quantity: 1)
              }
            case .edit(let product):
              store.updateProduct(product, name: name, category: category, unit: unit, emoji: savedEmoji, assetName: assetName, customImageData: savedPhoto)
            }
            dismiss()
          }
          .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
      }
    }
  }
}

struct ProductBaseListsSheet: View {
  @EnvironmentObject private var store: ShoppingStore
  @Environment(\.dismiss) private var dismiss
  let product: Product
  @State private var query = ""

  private var filtered: [PresetList] {
    store.presets.filter { query.isEmpty || $0.name.localizedCaseInsensitiveContains(query) }
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          HStack(spacing: 12) {
            ProductIcon(product: product, size: 58)
            VStack(alignment: .leading, spacing: 4) {
              Text(product.name)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(AppColors.text)
              Text("Anadir a listas base")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColors.muted)
            }
          }
          TextField("Buscar lista base", text: $query)
            .textFieldStyle(AppTextFieldStyle())
          ForEach(filtered) { preset in
            let enabled = store.presetContains(preset, product: product)
            Button {
              store.setProduct(product, in: preset, enabled: !enabled)
            } label: {
              HStack(spacing: 12) {
                ResourceIcon(name: preset.assetName, size: 46)
                VStack(alignment: .leading, spacing: 3) {
                  Text(preset.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(AppColors.text)
                  Text("\(preset.productNames.count) productos")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppColors.muted)
                }
                Spacer()
                Image(systemName: enabled ? "checkmark.circle.fill" : "circle")
                  .foregroundStyle(enabled ? AppColors.accent : AppColors.muted)
              }
              .padding(12)
              .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
          }
        }
        .padding(20)
      }
      .background(AppColors.background.ignoresSafeArea())
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Cerrar") { dismiss() }
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
        Text("\(item.quantity)")
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
  @State private var editing = false
  @State private var choosingBaseLists = false

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Button {
        store.add(product: product, quantity: quantity)
      } label: {
        VStack(alignment: .leading, spacing: 8) {
          ProductIcon(product: product, size: 54)
          VStack(alignment: .leading, spacing: 3) {
            Text(product.name)
              .font(.system(size: 16, weight: .bold))
              .foregroundStyle(AppColors.text)
              .lineLimit(2)
              .minimumScaleFactor(0.78)
              .fixedSize(horizontal: false, vertical: true)
            Text(product.category)
              .font(.system(size: 12, weight: .medium))
              .foregroundStyle(AppColors.muted)
              .lineLimit(1)
              .truncationMode(.tail)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      .buttonStyle(.plain)
      Spacer(minLength: 0)
      HStack(spacing: 8) {
        Button { editing = true } label: {
          Image(systemName: "pencil")
            .frame(width: 34, height: 30)
        }
        Button { choosingBaseLists = true } label: {
          Image(systemName: "star.badge.plus")
            .frame(width: 34, height: 30)
        }
      }
      .font(.system(size: 13, weight: .bold))
      .foregroundStyle(AppColors.accent)
    }
    .padding(12)
    .frame(maxWidth: .infinity, minHeight: 176, alignment: .leading)
    .dynamicTypeSize(.small ... .large)
    .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 8))
    .sheet(isPresented: $editing) {
      ProductEditorSheet(mode: .edit(product))
        .environmentObject(store)
    }
    .sheet(isPresented: $choosingBaseLists) {
      ProductBaseListsSheet(product: product)
        .environmentObject(store)
    }
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
    if let data = product.customImageData, let image = UIImage(data: data) {
      Image(uiImage: image)
        .resizable()
        .scaledToFill()
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    } else if !product.emoji.isEmpty {
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
