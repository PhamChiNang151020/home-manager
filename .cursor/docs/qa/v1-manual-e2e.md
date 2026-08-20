# v1 Manual E2E checklist

Format: **Precondition → Steps → Expected → Browser**

- Chrome: bắt buộc mọi TC
- Safari / iPhone Add to Home Screen: TC có tag `[PWA]`

---

## Auth

### TC-AUTH-01: Chưa đăng nhập thấy nút Google
- Precondition: Chưa có session Supabase
- Steps: Mở app
- Expected: Màn hình đăng nhập, nút Google hiển thị
- Browser: Chrome

### TC-AUTH-02: Đăng nhập thành công
- Precondition: Google account hợp lệ, Supabase OAuth cấu hình đúng
- Steps: Bấm Google → hoàn tất OAuth
- Expected: Vào shell (tab Điện / Cài đặt)
- Browser: Chrome, [PWA]

### TC-AUTH-03: Đăng xuất
- Precondition: Đã đăng nhập
- Steps: Cài đặt → Tài khoản → Đăng xuất
- Expected: Quay lại màn hình đăng nhập
- Browser: Chrome

### TC-AUTH-04: OAuth lỗi
- Precondition: Redirect URL sai hoặc user hủy OAuth
- Steps: Thử đăng nhập
- Expected: Hiện thông báo lỗi, không crash
- Browser: Chrome

---

## Homes

### TC-HOME-01: User mới — empty state
- Precondition: Account mới, chưa có nhà
- Steps: Đăng nhập
- Expected: Empty state + có thể tạo nhà
- Browser: Chrome

### TC-HOME-02: Tạo nhà meter
- Precondition: Đã đăng nhập
- Steps: Tạo nhà mode meter (Nhà tôi)
- Expected: Nhà xuất hiện; form điện có trường kWh
- Browser: Chrome

### TC-HOME-03: Tạo nhà invoice
- Precondition: Đã đăng nhập
- Steps: Tạo nhà mode invoice (Nhà ba mẹ)
- Expected: Form điện có tiền + ảnh, không bắt buộc kWh
- Browser: Chrome

### TC-HOME-04: Chuyển nhà
- Precondition: Có ≥ 2 nhà
- Steps: Mở home picker → chọn nhà khác
- Expected: Dashboard hiển thị data đúng nhà
- Browser: Chrome

---

## Electricity — Meter

### TC-ELEC-M01: Kỳ đầu — nhập prev + new
- Precondition: Nhà meter, chưa có kỳ nào
- Steps: Thêm kỳ, nhập previous + new kWh
- Expected: Amount = (new − prev) × rate
- Browser: Chrome

### TC-ELEC-M02: Kỳ sau — auto-fill previous
- Precondition: Đã có ít nhất 1 kỳ meter
- Steps: Thêm kỳ mới
- Expected: Previous kWh tự điền từ kỳ trước (nếu UI hỗ trợ)
- Browser: Chrome

### TC-ELEC-M03: new kWh < previous
- Precondition: Nhà meter
- Steps: Nhập new < prev → Lưu
- Expected: Lỗi invalid readings, không lưu
- Browser: Chrome

### TC-ELEC-M04: Thiếu kWh
- Precondition: Nhà meter
- Steps: Để trống prev hoặc new → Lưu
- Expected: Lỗi validation, không lưu
- Browser: Chrome

### TC-ELEC-M05: Trùng tháng — hint + confirm
- Precondition: Đã có kỳ tháng T
- Steps: Thêm kỳ cùng tháng T
- Expected: Hint vàng + dialog xác nhận ghi đè
- Browser: Chrome

### TC-ELEC-M06: Edit đổi tháng
- Precondition: Có kỳ tháng 01/2026
- Steps: Sửa kỳ → đổi sang 02/2026 → Lưu
- Expected: Kỳ 01/2026 biến mất; kỳ 02/2026 có data
- Browser: Chrome

### TC-ELEC-M07: Xoá kỳ
- Precondition: Có ít nhất 1 kỳ
- Steps: Mở kỳ → Xoá → xác nhận
- Expected: Kỳ biến mất khỏi list
- Browser: Chrome

---

## Electricity — Invoice

### TC-ELEC-I01: Nhập tiền + ảnh
- Precondition: Nhà invoice
- Steps: Thêm kỳ, nhập số tiền, chọn ảnh → Lưu
- Expected: Kỳ lưu OK, có ảnh
- Browser: Chrome, [PWA]

### TC-ELEC-I02: Tiền ≤ 0
- Precondition: Nhà invoice
- Steps: Nhập 0 hoặc để trống → Lưu
- Expected: Lỗi invalid amount
- Browser: Chrome

### TC-ELEC-I03: Reload giữ data
- Precondition: Đã lưu kỳ
- Steps: F5 / reload trang
- Expected: Data còn (Supabase sync)
- Browser: Chrome, [PWA]

---

## Settings & Invite

### TC-SET-01: Đổi kwh rate
- Precondition: Nhà meter
- Steps: Settings → đổi rate → thêm kỳ mới
- Expected: Amount tính theo rate mới
- Browser: Chrome

### TC-SET-02: Ngày nhắc — banner
- Precondition: Set photoDueDay = hôm nay
- Steps: Mở tab Điện
- Expected: Reminder banner hiển thị
- Browser: Chrome

### TC-SET-03: Download ICS
- Precondition: Nhà có photo/payday/remind day
- Steps: Settings → tải ICS
- Expected: File .ics có BEGIN:VCALENDAR + RRULE MONTHLY
- Browser: Chrome

### TC-INV-01: Owner mời email
- Precondition: User là owner
- Steps: Settings → Members → invite email
- Expected: Pending invite xuất hiện
- Browser: Chrome

### TC-INV-02: User được mời login
- Precondition: Invite pending cho email user
- Steps: User login Google đúng email
- Expected: Thấy nhà được mời
- Browser: Chrome

---

## Water

### TC-WATER-01: Thêm kỳ nước meter
- Precondition: Nhà meter, đã mở Tổng quan → Nước
- Steps: Thêm kỳ, nhập số cũ + số mới m³
- Expected: Amount = (new − prev) × m3_rate
- Browser: Chrome

### TC-WATER-02: Ảnh nước không ghi đè ảnh điện
- Precondition: Cùng tháng đã có ảnh điện
- Steps: Upload ảnh kỳ nước
- Expected: Path `homes/{id}/water/{yyyy-mm}.jpg`, ảnh điện vẫn còn
- Browser: Chrome

## Expenses

### TC-EXP-01: Thêm chi tiêu
- Precondition: Đã có nhà, tab Chi tiêu
- Steps: Thêm chi — số tiền, danh mục, người trả
- Expected: Xuất hiện trong list tháng hiện tại + pie chart
- Browser: Chrome

### TC-EXP-02: Filter theo danh mục
- Precondition: Có ≥ 2 category có chi
- Steps: Chọn 1 danh mục
- Expected: List chỉ hiện category đó
- Browser: Chrome

## Income / Overview

### TC-INC-01: Nhập lương thành viên
- Precondition: Nhà có ≥ 1 thành viên
- Steps: Tổng quan → Thu nhập → nhập lương → Lưu
- Expected: Tổng thu cập nhật; chênh lệch = thu − điện − nước − chi
- Browser: Chrome

### TC-OVW-01: Dashboard tháng
- Precondition: Có dữ liệu điện/nước/chi/thu trong tháng
- Steps: Mở tab Tổng quan, chọn tháng
- Expected: Card tổng thu / tổng chi / chênh lệch + breakdown category
- Browser: Chrome

---

## Regression (bug fix)

Khi fix bug, thêm dòng:

```
### TC-REG-xxx: [mô tả bug đã fix]
- Steps: ...
- Expected: không tái phát
```

Và thêm automated regression test trong [test-map.md](test-map.md).
