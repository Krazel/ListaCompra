import SwiftUI

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
  var tint: Int

  init(id: UUID = UUID(), name: String, category: String, unit: String, icon: String, tint: Int) {
    self.id = id
    self.name = name
    self.category = category
    self.unit = unit
    self.icon = icon
    self.tint = tint
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

struct PresetList: Identifiable, Codable, Equatable {
  let id: UUID
  var name: String
  var icon: String
  var productNames: [String]

  init(id: UUID = UUID(), name: String, icon: String, productNames: [String]) {
    self.id = id
    self.name = name
    self.icon = icon
    self.productNames = productNames
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
  @Published var items: [ShoppingItem] = [] { didSet { save() } }
  @Published var products: [Product] = [] { didSet { save() } }
  @Published var presets: [PresetList] = [] { didSet { save() } }
  @Published var members: [SharedMember] = [] { didSet { save() } }
  @Published var canEditSharedList = true { didSet { save() } }

  private var isLoading = true
  private let itemsKey = "shopping.items.v1"
  private let productsKey = "shopping.products.v1"
  private let presetsKey = "shopping.presets.v1"
  private let membersKey = "shopping.members.v1"
  private let editKey = "shopping.canEdit.v1"

  init() {
    load()
    isLoading = false
  }

  var pendingItems: [ShoppingItem] { items.filter { !$0.checked } }
  var doneItems: [ShoppingItem] { items.filter { $0.checked } }

  var shareText: String {
    let lines = items.map { "- \($0.product.name): \($0.quantity) \($0.product.unit)\($0.checked ? " (comprado)" : "")" }
    return "Lista de la compra\n" + lines.joined(separator: "\n")
  }

  func add(product: Product, quantity: Int) {
    let safeQuantity = max(1, quantity)
    if let index = items.firstIndex(where: { $0.product.name == product.name && !$0.checked }) {
      items[index].quantity += safeQuantity
    } else {
      items.insert(ShoppingItem(product: product, quantity: safeQuantity), at: 0)
    }
  }

  func addCustomProduct(name: String, category: String) {
    let cleaned = name.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !cleaned.isEmpty else { return }
    if products.contains(where: { $0.name.localizedCaseInsensitiveCompare(cleaned) == .orderedSame }) { return }
    products.append(Product(name: cleaned, category: category.isEmpty ? "Otros" : category, unit: "ud", icon: "cart", tint: products.count % 6))
  }

  func toggle(_ item: ShoppingItem) {
    guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
    items[index].checked.toggle()
  }

  func increment(_ item: ShoppingItem) {
    guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
    items[index].quantity += 1
  }

  func decrement(_ item: ShoppingItem) {
    guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
    items[index].quantity = max(1, items[index].quantity - 1)
  }

  func delete(_ item: ShoppingItem) {
    items.removeAll { $0.id == item.id }
  }

  func clearChecked() {
    items.removeAll { $0.checked }
  }

  func usePreset(_ preset: PresetList) {
    for name in preset.productNames {
      if let product = products.first(where: { $0.name == name }) {
        add(product: product, quantity: 1)
      }
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
    items = decode([ShoppingItem].self, key: itemsKey) ?? Self.defaultItems(from: products)
    presets = decode([PresetList].self, key: presetsKey) ?? Self.defaultPresets
    members = decode([SharedMember].self, key: membersKey) ?? [SharedMember(name: "Yo"), SharedMember(name: "Casa")]
    canEditSharedList = UserDefaults.standard.object(forKey: editKey) as? Bool ?? true
  }

  private func save() {
    guard !isLoading else { return }
    encode(products, key: productsKey)
    encode(items, key: itemsKey)
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
    Product(name: "Pan", category: "Despensa", unit: "ud", icon: "baguette", tint: 1),
    Product(name: "Leche", category: "Frescos", unit: "l", icon: "drop", tint: 2),
    Product(name: "Huevos", category: "Frescos", unit: "doc", icon: "circle.grid.cross", tint: 3),
    Product(name: "Tomates", category: "Frescos", unit: "ud", icon: "circle.fill", tint: 4),
    Product(name: "Platanos", category: "Fruta", unit: "ud", icon: "leaf", tint: 5),
    Product(name: "Manzanas", category: "Fruta", unit: "kg", icon: "apple.logo", tint: 4),
    Product(name: "Arroz", category: "Despensa", unit: "kg", icon: "shippingbox", tint: 1),
    Product(name: "Pasta", category: "Despensa", unit: "paq", icon: "takeoutbag.and.cup.and.straw", tint: 1),
    Product(name: "Cafe", category: "Desayuno", unit: "paq", icon: "cup.and.saucer", tint: 1),
    Product(name: "Detergente", category: "Limpieza", unit: "ud", icon: "bubbles.and.sparkles", tint: 2),
    Product(name: "Papel cocina", category: "Limpieza", unit: "paq", icon: "square.stack.3d.up", tint: 0),
    Product(name: "Congelados", category: "Congelador", unit: "bol", icon: "snowflake", tint: 2)
  ]

  static func defaultItems(from products: [Product]) -> [ShoppingItem] {
    ["Pan", "Leche", "Huevos", "Tomates"].compactMap { name in
      products.first(where: { $0.name == name }).map { ShoppingItem(product: $0, quantity: name == "Huevos" ? 1 : 2) }
    }
  }

  static let defaultPresets: [PresetList] = [
    PresetList(name: "Compra semanal", icon: "calendar", productNames: ["Pan", "Leche", "Huevos", "Tomates", "Platanos", "Arroz"]),
    PresetList(name: "Desayuno", icon: "sun.max", productNames: ["Pan", "Leche", "Cafe", "Huevos"]),
    PresetList(name: "Limpieza", icon: "sparkles", productNames: ["Detergente", "Papel cocina"]),
    PresetList(name: "Cena rapida", icon: "fork.knife", productNames: ["Pasta", "Tomates", "Congelados"])
  ]
}

struct RootView: View {
  var body: some View {
    TabView {
      ListScreen().tabItem { Label("Lista", systemImage: "checklist") }
      AddScreen().tabItem { Label("Anadir", systemImage: "plus.circle") }
      PresetsScreen().tabItem { Label("Listas", systemImage: "rectangle.grid.2x2") }
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
        VStack(alignment: .leading, spacing: 16) {
          Header(title: "Lista de la compra", subtitle: "\(store.pendingItems.count) pendientes")
          HStack(spacing: 10) {
            Chip(text: "Compartida", icon: "person.2.fill")
            Chip(text: "\(store.members.count) personas", icon: "link")
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
            Button {
              store.addCustomProduct(name: customName, category: customCategory)
              customName = ""
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

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          Header(title: "Listas base", subtitle: "Plantillas personales para repetir compras.")
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
              Label("\(store.members.count) personas", systemImage: "person.2.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(AppColors.text)
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
        Image(systemName: preset.icon)
          .font(.system(size: 20, weight: .bold))
          .foregroundStyle(AppColors.accent)
          .frame(width: 44, height: 44)
          .background(AppColors.accent.opacity(0.14), in: RoundedRectangle(cornerRadius: 8))
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
    Image(systemName: product.icon)
      .font(.system(size: size * 0.42, weight: .bold))
      .foregroundStyle(iconColor(product.tint))
      .frame(width: size, height: size)
      .background(iconColor(product.tint).opacity(0.16), in: RoundedRectangle(cornerRadius: 8))
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
