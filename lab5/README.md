# Lab 5 - Simple Note App (Flutter)

Ứng dụng ghi chú đơn giản được xây dựng bằng Flutter theo yêu cầu Lab 5:
- Tạo ghi chú mới
- Xem danh sách ghi chú
- Chỉnh sửa ghi chú
- Xóa ghi chú có xác nhận
- Lưu trữ dữ liệu cục bộ bằng SQLite
- Theo dõi thời gian tạo/cập nhật

## 1. Công nghệ sử dụng
- Flutter (Material 3)
- Dart
- `sqflite`: SQLite local database
- `path_provider`: lấy đường dẫn lưu dữ liệu trên thiết bị
- `provider`: quản lý state
- `intl`: format ngày giờ

## 2. Cấu trúc thư mục
```text
lib/
├── models/
│   └── note.dart
├── database/
│   └── db_helper.dart
├── providers/
│   └── note_provider.dart
├── screens/
│   ├── home_page.dart
│   └── note_editor_screen.dart
├── widgets/
│   └── note_card.dart
└── main.dart
```

## 3. Chức năng chính
### 3.1. Tạo ghi chú
- Nhập `title` và `content` trong màn hình `NoteEditorScreen`
- Lưu thời gian `createdAt` và `updatedAt`

### 3.2. Xem danh sách ghi chú
- Hiển thị bằng `ListView`
- Sắp xếp theo `updatedAt` giảm dần (mới cập nhật lên đầu)

### 3.3. Chỉnh sửa ghi chú
- Nhấn vào thẻ ghi chú để mở màn hình sửa
- Khi cập nhật, `updatedAt` được cập nhật theo thời gian hiện tại

### 3.4. Xóa ghi chú
- Có hộp thoại xác nhận trước khi xóa

### 3.5. Lưu trữ cục bộ
- SQLite DB tên `notes.db`
- Bảng `notes` gồm các cột:
  - `id` (INTEGER PRIMARY KEY AUTOINCREMENT)
  - `title` (TEXT NOT NULL)
  - `content` (TEXT NOT NULL)
  - `createdAt` (TEXT NOT NULL)
  - `updatedAt` (TEXT NOT NULL)

## 4. Kiến trúc dữ liệu và state
- `DatabaseHelper`: singleton quản lý kết nối DB và CRUD
- `NoteProvider`: quản lý danh sách note và cập nhật UI qua `notifyListeners()`
- `HomePage`: hiển thị danh sách, thao tác thêm/sửa/xóa
- `NoteEditorScreen`: form tạo/sửa note

## 5. Cài đặt và chạy project
### 5.1. Yêu cầu
- Flutter SDK
- Dart SDK
- Android Studio hoặc VS Code (Flutter extension)

### 5.2. Chạy ứng dụng
```bash
flutter pub get
flutter run
```

### 5.3. Kiểm tra mã nguồn
```bash
flutter analyze
flutter test
```

## 6. Dữ liệu được lưu ở đâu?
Dữ liệu được lưu local trong SQLite file `notes.db`, tại thư mục application documents của app trên thiết bị (lấy bằng `getApplicationDocumentsDirectory()`).

## 7. Đối chiếu yêu cầu Lab 5
- [x] Dùng `sqflite` để lưu local database
- [x] Dùng `provider` để quản lý state
- [x] Tạo ghi chú mới
- [x] Hiển thị danh sách ghi chú
- [x] Chỉnh sửa ghi chú
- [x] Xóa ghi chú có xác nhận
- [x] Lưu timestamp tạo/cập nhật

## 8. Ghi chú
- App hiện dùng giao diện sáng, nhẹ nhàng, dễ nhìn.
- Nếu cần nộp bài, có thể thêm ảnh chụp màn hình phần: danh sách note, thêm note, sửa note, xác nhận xóa.
