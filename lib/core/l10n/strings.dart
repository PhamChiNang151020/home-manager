abstract final class S {
  static const appName = "Tổ Ấm";
  static const appTagline = "Giữ ấm tổ ấm, giữ vững chi tiêu";
  static const signInGoogle = "Đăng nhập bằng Google";
  static const signInHint =
      "Dùng tài khoản Google để đồng bộ điện với gia đình.";
  static const missingConfig =
      "Chưa cấu hình Supabase. Chạy với --dart-define=SUPABASE_URL và SUPABASE_ANON_KEY.";
  static const electricity = "Điện";
  static const water = "Nước";
  static const overview = "Tổng quan";
  static const income = "Thu nhập";
  static const addIncome = "Lưu lương tháng";
  static const noIncome = "Chưa nhập lương tháng này";
  static const incomeSource = "Nguồn";
  static const salary = "Lương";
  static const monthIncome = "Tổng thu";
  static const monthSpend = "Tổng chi";
  static const monthNet = "Chênh lệch";
  static const expenses = "Chi tiêu";
  static const addExpense = "Thêm chi tiêu";
  static const editExpense = "Sửa chi tiêu";
  static const deleteExpense = "Xóa chi tiêu";
  static const deleteExpenseConfirm = "Xóa khoản chi này? Không thể hoàn tác.";
  static const noExpenses = "Chưa có chi tiêu nào trong tháng này";
  static const category = "Danh mục";
  static const paidBy = "Người trả";
  static const expenseDate = "Ngày chi";
  static const receiptPhoto = "Ảnh hoá đơn";
  static const spendByCategory = "Chi theo danh mục";
  static const invalidExpenseAmount = "Nhập số tiền chi hợp lệ.";
  static const settings = "Cài đặt";
  static const signOut = "Đăng xuất";
  static const homes = "Nhà";
  static const addHome = "Thêm nhà";
  static const homeName = "Tên nhà";
  static const trackingMode = "Cách nhập điện / nước";
  static const modeMeter = "Nhập số công tơ — tự tính tiền";
  static const modeInvoice = "Nhập tiền trên hoá đơn";
  static const modeMeterHint =
      "Nhà có đồng hồ. Mỗi kỳ nhập số cũ và số mới; app nhân với đơn giá.";
  static const modeInvoiceHint =
      "Nhà nhận hoá đơn MoMo hoặc ngân hàng. Chỉ nhập số tiền và ảnh.";
  static const save = "Lưu";
  static const edit = "Sửa";
  static const delete = "Xóa";
  static const cancel = "Huỷ";
  static const kwhRate = "Đơn giá (đ/kWh)";
  static const m3Rate = "Đơn giá (đ/m³)";
  static const previousKwh = "Số cũ (kWh)";
  static const newKwh = "Số mới (kWh)";
  static const previousM3 = "Số cũ (m³)";
  static const newM3 = "Số mới (m³)";
  static const consumption = "Tiêu thụ";
  static const amount = "Số tiền (đ)";
  static const month = "Tháng";
  static const selectMonth = "Chọn tháng";
  static const previousMonth = "Tháng trước";
  static const nextMonth = "Tháng sau";
  static const spendTrend = "Tổng chi 6 tháng";
  static const ok = "OK";
  static const done = "Xong";
  static const note = "Ghi chú";
  static const photo = "Ảnh hoá đơn";
  static const pickPhoto = "Chụp hoặc chọn ảnh";
  static const addPeriod = "Thêm kỳ điện";
  static const editPeriod = "Sửa kỳ điện";
  static const deletePeriod = "Xóa kỳ điện";
  static const deletePeriodConfirm = "Xóa kỳ điện này? Không thể hoàn tác.";
  static const addWaterPeriod = "Thêm kỳ nước";
  static const editWaterPeriod = "Sửa kỳ nước";
  static const deleteWaterPeriod = "Xóa kỳ nước";
  static const deleteWaterPeriodConfirm =
      "Xóa kỳ nước này? Không thể hoàn tác.";
  static const duplicatePeriodTitle = "Kỳ điện đã tồn tại";
  static const duplicatePeriodConfirm =
      "Tháng này đã có kỳ điện. Ghi đè dữ liệu cũ?";
  static const duplicatePeriodHint = "Tháng này đã có kỳ điện";
  static const duplicateWaterPeriodTitle = "Kỳ nước đã tồn tại";
  static const duplicateWaterPeriodConfirm =
      "Tháng này đã có kỳ nước. Ghi đè dữ liệu cũ?";
  static const duplicateWaterPeriodHint = "Tháng này đã có kỳ nước";
  static const overwrite = "Ghi đè";
  static const noHomes = "Chưa có nhà. Tạo nhà hoặc nhận lời mời.";
  static const noPeriods = "Chưa có kỳ điện nào được ghi nhận";
  static const noWaterPeriods = "Chưa có kỳ nước nào được ghi nhận";
  static const invite = "Mời thành viên";
  static const inviteEmail = "Email Google";
  static const sendInvite = "Gửi lời mời";
  static const members = "Thành viên";
  static const owner = "Chủ nhà";
  static const member = "Thành viên";
  static const pendingInvites = "Lời mời đang chờ";
  static const photoDueDay = "Ngày chụp hoá đơn";
  static const payday = "Ngày lãnh lương";
  static const remindDay = "Ngày nhắc";
  static const dayOfMonth = "Ngày trong tháng (1–31)";
  static const exportIcs = "Tải lịch nhắc (.ics)";
  static const bannerPhoto = "Hôm nay đến ngày chụp hoá đơn điện / nước.";
  static const bannerPayday = "Hôm nay là ngày lãnh lương.";
  static const bannerRemind = "Hôm nay đến ngày nhắc đóng / ghi điện và nước.";
  static const firstPeriodHint = "Kỳ đầu: nhập cả số cũ và số mới.";
  static const firstWaterPeriodHint = "Kỳ nước đầu: nhập cả số cũ và số mới.";
  static const invalidReadings = "Số mới phải lớn hơn hoặc bằng số cũ.";
  static const invalidAmount = "Nhập số tiền hợp lệ.";
  static const roleOwnerOnly = "Chỉ chủ nhà mới sửa cài đặt và mời người.";
  static const switchHome = "Chọn nhà";
  static const lastPeriod = "Kỳ gần nhất";
  static const avgSixMonths = "TB 6 tháng";
  static const trendSixMonths = "6 tháng gần đây";
  static const hasPhoto = "Có ảnh";
  static const viewPhoto = "Xem ảnh";
  static const noPhoto = "Chưa ảnh";
  static const retry = "Thử lại";
  static const settingsHome = "Nhà";
  static const settingsSchedule = "Lịch nhắc";
  static const settingsMembers = "Thành viên";
  static const settingsAccount = "Tài khoản";
  static const settingsAppearance = "Giao diện";
  static const settingsSecurity = "Bảo mật";
  static const settingsInstall = "Thêm ra Màn hình chính";
  static const settingsHomeDesc = "Tên nhà, đơn giá điện / nước";
  static const settingsScheduleDesc = "Ngày chụp, lương, nhắc · xuất .ics";
  static const settingsMembersDesc = "Thành viên và lời mời";
  static const settingsAccountDesc = "Đăng xuất";
  static const settingsAppearanceDesc = "Sáng / tối, màu nhấn";
  static const settingsSecurityDesc = "Khoá ứng dụng bằng PIN";
  static const settingsInstallDesc = "iPhone: cài nhanh · QR gửi người nhà";
  static const installBannerTitle = "Thêm Tổ Ấm ra Màn hình chính";
  static const installBannerIosSafari =
      "Bấm Cài nhanh → Cài đặt → Cài. iOS có thể báo Chưa xác minh — bấm Cài tiếp.";
  static const installBannerIosInApp =
      "Zalo không cài được. Bấm ⋯ → Mở bằng Safari, rồi bấm Cài nhanh trên iPhone.";
  static const installBannerAndroid =
      "Chrome → menu ⋮ → Cài đặt ứng dụng (hoặc Thêm vào màn hình chính).";
  static const installBannerAndroidInApp =
      "Mở bằng Chrome, đừng mở trong Zalo. Rồi menu ⋮ → Thêm vào màn hình chính.";
  static const installIosWebClip = "Cài nhanh trên iPhone";
  static const installIosWebClipSteps =
      "Bấm Cài nhanh → Cho phép → Cài đặt → Cài. iOS có thể báo \"Chưa xác minh\" — bấm Cài tiếp.";
  static const installIosWebClipInApp =
      "Mở bằng Safari trước, rồi bấm Cài nhanh trên iPhone.";
  static const installGuide = "Mã QR gửi người nhà";
  static const installDismiss = "Đóng";
  static const installQrSectionTitle = "Gửi cho người nhà";
  static const installQrHint =
      "Chụp màn hình mã này rồi gửi ảnh. Người nhà mở Safari, quét mã, bấm Cài nhanh trên trang mở ra.";
  static const installCopyLink = "Sao chép liên kết (cho bạn)";
  static const installLinkCopied = "Đã sao chép liên kết";
  static const installIosProfileRemoveTitle = "Gỡ profile khỏi iPhone";
  static const installIosProfileRemoveSteps =
      "Cài đặt → Cài đặt chung → VPN và Quản lý thiết bị → Cài Tổ Ấm lên iPhone → Gỡ cấu hình.";
  static const installIosProfileRemoveNote =
      "Gỡ profile sẽ xóa icon Tổ Ấm trên Màn hình chính. Cài lại bằng Cài nhanh trên iPhone ở trên.";
  static const themeModeLabel = "Chế độ";
  static const themeModeSystem = "Hệ thống";
  static const themeModeLight = "Sáng";
  static const themeModeDark = "Tối";
  static const themeAccent = "Màu nhấn";
  static const history = "Lịch sử";
  static const filterAll = "Tất cả";
  static const filterYear = "Năm";
  static const filterMonth = "Tháng";
  static const sortNewest = "Mới nhất";
  static const sortOldest = "Cũ nhất";
  static const sortLabel = "Sắp xếp";
  static const recordedAt = "Ngày ghi";
  static const selectRecordedAt = "Chọn ngày giờ ghi";
  static const hasNote = "Có ghi chú";
  static const noHistoryMatch = "Không có kỳ điện phù hợp bộ lọc";
  static const noWaterHistoryMatch = "Không có kỳ nước phù hợp bộ lọc";
  static const detailPeriod = "Chi tiết kỳ điện";
  static const detailWaterPeriod = "Chi tiết kỳ nước";
  static const cancelInvite = "Huỷ lời mời";
  static const cancelInviteConfirm = "Huỷ lời mời đã gửi đến";
  static const pendingInviteHint = "Đang chờ chấp nhận";
  static const sending = "Đang gửi…";
  static const paid = "Đã thanh toán";
  static const unpaid = "Chưa chốt số";
  static const markPaid = "Đánh dấu đã thanh toán";
  static const markUnpaid = "Bỏ đánh dấu";
  static const appVersion = "Phiên bản";

  // Lock / PIN
  static const lockTitle = "Nhập PIN";
  static const lockWrongPin = "PIN không đúng";
  static const setupPinTitle = "Tạo mã PIN";
  static const setupPinConfirmTitle = "Xác nhận PIN";
  static const setupPinMismatch = "Hai lần nhập không khớp";
  static const setupPinTooShort = "PIN cần đủ 6 số";
  static const changePin = "Đổi PIN";
  static const enableAppLock = "Khoá ứng dụng";
  static const appLockNotEnabled = "Chưa bật khoá ứng dụng";
  static const autoLockLabel = "Tự khoá khi tạm ẩn app";
  static const autoLockImmediate = "Ngay lập tức";
  static const autoLockOneMinute = "Sau 1 phút";
  static const autoLockFiveMinutes = "Sau 5 phút";
  static const disableAppLock = "Tắt khoá ứng dụng";

  // Finance hub
  static const finance = "Tài chính";
  static const bankCredit = "Tín dụng NH";
  static const personalDebts = "Nợ vay mượn";
  static const savings = "Tiết kiệm";
  static const bankCreditDesc = "Thẻ tín dụng, hạn mức, sao kê";
  static const personalDebtsDesc = "Mình nợ / người khác nợ mình";
  static const savingsDesc = "Gửi kỳ hạn và mục tiêu tiết kiệm";
  static const addBankAccount = "Thêm thẻ / hạn mức";
  static const editBankAccount = "Sửa thẻ / hạn mức";
  static const bankName = "Ngân hàng";
  static const bankPickHint = "Chọn ngân hàng";
  static const bankOther = "Khác / tự nhập";
  static const creditLimit = "Hạn mức (đ)";
  static const statementDay = "Ngày chốt sao kê";
  static const dueDay = "Ngày đến hạn";
  static const balanceUsed = "Đã sử dụng (đ)";
  static const paymentDue = "Số phải trả (đ)";
  static const paymentMade = "Đã trả (đ)";
  static const remainingCredit = "Còn lại";
  static const addBankPeriod = "Thêm kỳ sao kê";
  static const editBankPeriod = "Sửa kỳ sao kê";
  static const noBankAccounts = "Chưa có thẻ tín dụng nào";
  static const deleteBankAccount = "Xóa thẻ";
  static const deleteBankAccountConfirm =
      "Xóa thẻ và mọi kỳ sao kê? Không thể hoàn tác.";
  static const invalidDay = "Ngày phải từ 1 đến 31";

  // Personal debts
  static const iOwe = "Mình nợ";
  static const owedToMe = "Nợ mình";
  static const addDebt = "Thêm khoản nợ";
  static const editDebt = "Sửa khoản nợ";
  static const counterparty = "Người liên quan";
  static const principalAmount = "Số gốc (đ)";
  static const remainingAmount = "Còn lại (đ)";
  static const dueDate = "Hạn trả";
  static const interestRate = "Lãi suất (%/năm)";
  static const settled = "Đã tất toán";
  static const openDebt = "Đang mở";
  static const addPayment = "Ghi nhận trả";
  static const paymentHistory = "Lịch sử trả";
  static const noDebts = "Chưa có khoản nợ nào";
  static const debtDirection = "Chiều nợ";
  static const deleteDebt = "Xóa khoản nợ";
  static const deleteDebtConfirm = "Xóa khoản nợ này? Không thể hoàn tác.";

  // Savings
  static const termDeposit = "Sổ tiết kiệm ngân hàng";
  static const savingsGoal = "Tiết kiệm mục tiêu";
  static const addSavings = "Thêm tiết kiệm";
  static const editSavings = "Sửa tiết kiệm";
  static const savingsType = "Loại";
  static const savingsName = "Tên";
  static const termMonths = "Kỳ hạn (tháng)";
  static const maturityDate = "Ngày đáo hạn";
  static const targetAmount = "Mục tiêu (đ)";
  static const currentAmount = "Số dư hiện tại (đ)";
  static const addContribution = "Nạp thêm";
  static const noSavings = "Chưa có khoản tiết kiệm nào";
  static const daysToMaturity = "Còn {days} ngày đến đáo hạn";
  static const matured = "Đã đến hạn";
  static const deleteSavings = "Xóa tiết kiệm";
  static const deleteSavingsConfirm =
      "Xóa khoản tiết kiệm này? Không thể hoàn tác.";
}
