# Advanced Calculator
## Project description and features
### Đây là một ứng dụng máy tính cao cấp được phát triển bằng Flutter, cung cấp trải nghiệm người dùng chuyên nghiệp với đầy đủ các tính năng từ cơ bản đến chuyên sâu. Dự án tập trung vào việc xử lý các biểu thức toán học phức tạp, quản lý trạng thái nâng cao và tối ưu hóa UI/UX.
- Các tính năng chính:
- +Ba chế độ hoạt động: Chế độ Cơ bản (Basic), Khoa học (Scientific) và Lập trình viên (Programmer).
- +Xử lý biểu thức thông minh: Hỗ trợ thứ tự ưu tiên toán tử (PEMDAS), đóng mở ngoặc và nhân ẩn (ví dụ: 2π).
- +Hàm khoa học đầy đủ: Lượng giác (sin, cos, tan), logarit (ln, log), lũy thừa, căn bậc n, giai thừa và các hằng số toán học (π, e).
- +Quản lý lịch sử: Lưu trữ và hiển thị lịch sử tính toán (lên đến 100 mục) có khả năng lưu trữ lâu dài (persistence).
- +Chế độ giao diện (Theming): Hỗ trợ Dark Mode và Light Mode với khả năng chuyển đổi mượt mà.
- +Chức năng nhớ (Memory): Đầy đủ các phím M+, M-, MR, MC.
- +Cài đặt tùy chỉnh: Điều chỉnh độ chính xác số thập phân (2-10 chữ số), đơn vị góc (Degrees/Radians) và phản hồi xúc giác (Haptic Feedback).
- +Điều khiển bằng cử chỉ: Vuốt để xóa ký tự, nhấn giữ để xóa lịch sử, vuốt lên để mở bảng lịch sử.

### Three calculator modes (Basic, Scientific, Programmer)
<img width="390" height="895" alt="image" src="https://github.com/user-attachments/assets/d4247643-690e-440c-9f81-979efbe5c559" />
<img width="390" height="895" alt="image" src="https://github.com/user-attachments/assets/d4aa5aa0-9912-48c6-a02e-52809855f16b" />
<img width="390" height="895" alt="image" src="https://github.com/user-attachments/assets/936dc79e-fd3c-4725-a300-5a871338285e" />

### Expression evaluation with proper precedence
<img width="390" height="895" alt="image" src="https://github.com/user-attachments/assets/e52ed6f2-c63c-4fef-b0cb-36efc41961e1" />
<img width="390" height="895" alt="image" src="https://github.com/user-attachments/assets/aefce99f-1fd9-4d34-b421-bc7e9111f388" />

### Calculation history with persistence
<img width="390" height="895" alt="image" src="https://github.com/user-attachments/assets/60e04b2c-e27f-4da6-8b6f-1212206b2ed8" />

### Dark/Light theme with smooth transitions
-Light
<img width="390" height="895" alt="image" src="https://github.com/user-attachments/assets/182e6663-2043-4c3f-9de2-73c76a7d9b09" />
-Dark
<img width="390" height="895" alt="image" src="https://github.com/user-attachments/assets/01cf0a20-97e0-4830-b7a7-26c0ed2faf4b" />

### Scientific functions (trig, log, power, etc.)
<img width="390" height="895" alt="image" src="https://github.com/user-attachments/assets/a6189c16-c9a8-440d-ae87-56d6a46373db" />
<img width="390" height="895" alt="image" src="https://github.com/user-attachments/assets/4c0b9c6e-0562-4bc9-a6ad-b23fdbd0c630" />

### Settings screen with customization
<img width="390" height="895" alt="image" src="https://github.com/user-attachments/assets/e9647b52-480b-4d65-8b52-e9a921c6166c" />

### Unit tests with >80% coverage
<img width="582" height="295" alt="image" src="https://github.com/user-attachments/assets/39b15e42-fc1e-4d55-89f4-dcc82dbc79ad" />

## Architecture Diagram
### Dự án được xây dựng theo kiến trúc phân lớp (Clean Architecture) để tách biệt rõ ràng giữa logic nghiệp vụ và giao diện người dùng:
    graph TD
    A[main.dart] --> B[Providers]
    B --> C[CalculatorProvider]
    B --> D[ThemeProvider]
    B --> E[HistoryProvider]
    
    C --> F[Services/StorageService]
    C --> G[Utils/ExpressionParser]
    
    H[Screens] --> B
    H --> I[Widgets]
    
    subgraph Layers
        direction LR
        UI[Screens/Widgets]
        Logic[Providers/Utils]
        Data[Models/Services]
    end
- Models: Định nghĩa cấu trúc dữ liệu (History, Settings).
- Providers: Quản lý trạng thái ứng dụng bằng Provider pattern.
- Services: Xử lý lưu trữ dữ liệu cục bộ qua SharedPreferences.
- Utils: Chứa logic xử lý toán học và phân tích cú pháp biểu thức

## Setup Instructions
Để cài đặt và chạy dự án này cục bộ, hãy làm theo các bước sau:
### 1. Clone repository:
git clone https://github.com/CuongNguyen12345/NguyenChiCuong_TH_Flutter

### 2. Cài đặt dependencies: Đảm bảo bạn đã cài đặt Flutter SDK.
flutter pub get

### 3. Kiểm tra các package quan trọng: Dự án sử dụng math_expressions, provider, và shared_preferences
### 4. Chạy ứng dụng:
flutter run

## Testing Instructions
Dự án yêu cầu độ bao phủ kiểm thử (test coverage) trên 80%.
### Unit Tests: Kiểm tra logic toán học, thứ tự ưu tiên toán tử và các hàm khoa học.
flutter test

## Known Limitations
- Chế độ Programmer hiện tại chủ yếu hỗ trợ các phép toán bitwise cơ bản, chưa hỗ trợ đầy đủ các kiểu dữ liệu signed/unsigned 64-bit phức tạp.
- Việc hiển thị các biểu thức toán học quá dài trên màn hình nhỏ có thể gây hiện tượng tràn chữ nếu không cuộn ngang.
- Độ chính xác của các số thập phân cực lớn có thể bị giới hạn bởi kiểu dữ liệu double của Dart.

## Future Improvements
- Hỗ trợ Landscape Mode: Tối ưu hóa giao diện khi xoay ngang màn hình.
- Vẽ đồ thị (Graph Plotting): Thêm tính năng vẽ đồ thị cho các hàm số toán học.
- Nhập liệu bằng giọng nói: Tích hợp AI để nhận diện biểu thức qua giọng nói.
- Xuất dữ liệu: Cho phép xuất lịch sử tính toán ra định dạng CSV hoặc PDF.
- Tùy chỉnh Theme: Cho phép người dùng tự tạo bảng màu giao diện riêng.
