# Invoice — quy ước dự án

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
