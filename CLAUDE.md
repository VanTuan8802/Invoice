# Invoice — quy ước dự án

## Màn hình & điều hướng

- Design: Figma `Invoice iOS` (bản "Invoice iOS 27"). SwiftUI, deploy iOS 16 — API iOS 26 (glass) phải
  bọc `if #available(iOS 26.0, *)`.
- Một stack điều hướng gốc là Home (`Container.homeNavi`): `app.navi.push(.client(.edit(id: nil)))`,
  `app.navi.push(..., type: .sheet())`, `app.navi.pop()`.
- Mỗi chức năng có route enum riêng `Views/<Feature>/<Feature>Route.swift` (case + `identifier` +
  `screen` + `debugPreviews`). `Destination` chỉ chuyển tiếp, không thêm switch riêng cho màn.
- Router ẩn navigation bar hệ thống: mỗi màn tự vẽ `BasicHeaderView` (nút tròn glass + tiêu đề giữa,
  trailing `HeaderIconButton` / `HeaderTextButton`) hoặc `LargeTitleHeader`.
- Component chung (`Common/Components`, `Common/DesignSystem`): `PrimaryButton(.primary/.outline)`,
  `FloatingActionButton` / `.floatingActionButton {}`, `SearchEntryField`, `LabeledInputField`,
  `EmptyStateView`, `.cardSurface()`, `.groupedScreenBackground()`, `.glassCircle()`, `.glassCapsule()`.
- Danh sách tuỳ chọn (Options sheet của design) dùng `.optionsSheet(isPresented:) { Button… }`, không dùng
  `confirmationDialog` (iOS 26 hiện thành popover nhỏ); sheet tự thêm Cancel.
- Hộp thoại "rời đi khi chưa lưu" (Discard trái, nút giữ lại xanh bên phải) dùng
  `.discardAlert(_:isPresented:keepTitle:) { … }`, không dùng `.alert` (iOS 26 chèn thêm Cancel).
- Form kiểu iOS (nhãn trái, giá trị phải, nhóm bo góc) dùng `Form`/`List` `.insetGrouped`, không tự dựng.
- Dữ liệu (`Domain/`): model `Document` (invoice/estimate), `Client`, `CatalogItem`, `BusinessProfile`;
  `DataStore` (`Container.dataStore`) giữ dữ liệu mẫu trong bộ nhớ; `DocumentEditor`
  (`Container.documentEditor`) là tài liệu đang sửa, dùng chung cho editor và các màn field.
- Text key đặt tiền tố theo chức năng (`home_`, `onboarding_`, `doc_`, `field_`, `client_`, `item_`,
  `reports_`, `settings_`), ghi vào đúng khu `/* ===== … ===== */` của chức năng trong cả 6 file.
  Hành động chung: `save`, `continue`, `skip`, `next`, `back`, `get_started`, `common_*`.
- Kiểm tra trên simulator (DEBUG): `-uiPreview <key>` mở thẳng route (bỏ qua splash/ads/onboarding),
  `-uiPreviewEmpty` để dữ liệu rỗng. Build dòng lệnh cần `-skipPackagePluginValidation`.

## Tài nguyên: luôn dùng R.swift

- Text: `R.stringLocalizable.<key>()` (theo ngôn ngữ chọn trong app). Key có `%d`/`%@` là hàm có
  tham số: `R.stringLocalizable.item_number(id)`. Không dùng chuỗi key thô hay `NSLocalizedString`.
  Thêm key vào cả 6 file `Invoice/Resources/Localizable/<lang>.lproj/Localizable.strings`.
- Ảnh / icon: `Image(R.image.<tên>)`, UIKit: `UIImage(resource: R.image.<tên>)`.
- Màu: `Color(R.color.<tên>)`, UIKit: `UIColor(resource: R.color.<tên>)`.
- Không gọi `Image("…")`, `UIImage(named:)`, `Color("…")` bằng chuỗi.
- SF Symbols (`Image(systemName:)`) giữ nguyên, R.swift không gen cho symbol hệ thống.

## Thư mục Assets (`Invoice/Resources/Assets.xcassets`)

```
Assets.xcassets/
├── AppIcon, AccentColor     # tên Xcode dành riêng, để nguyên ở gốc
├── Colors/                  # colorRRGGBB.colorset
├── Icons/<ChứcNăng>/        # icon, chia folder theo chức năng
└── Images/<ChứcNăng>/       # ảnh, chia folder theo chức năng
```

- **Colors**: tên = `color` + mã hex 6 ký tự in hoa, vd `colorFFFFFF`, `color1A2B3C`
  → `R.color.colorFFFFFF`. Tên chính là mã màu nên mỗi colorset chỉ chứa đúng màu đó; mã đã có
  thì dùng lại, không tạo bản thứ hai.
- **Icons / Images**: mỗi chức năng (màn hình / tính năng) một folder con, vd `Icons/Home`,
  `Images/Intro`, `Icons/Settings`; asset dùng ở nhiều màn để trong `Common`. Tạo folder khi thêm
  asset đầu tiên của chức năng đó.
- Các folder **không** bật *Provides Namespace*, nên R.swift gen tên phẳng (`R.image.ic_home_add`).
  Vì vậy tên asset phải duy nhất trong toàn catalog: đặt tên kèm chức năng, vd `ic_home_add`,
  `img_intro_1`.
