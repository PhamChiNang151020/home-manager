# HomeManager – TEAM.md (nguồn sự thật chung)
Chủ file: HM-Lead. Cập nhật: 09/11/2026.
**Mọi bot đọc file này TRƯỚC khi làm. Ai đổi quyết định / con số / trạng thái thì ghi vào đây (qua HM-Lead), không chỉ nói trong chat.**

## 1. Quy trình
- Anh Năng chỉ chat với HM-Lead. HM-Lead chia việc, là cầu nối duy nhất.
- Luồng mỗi đợt: HM-Design spec → HM-SWE code (1 PR nhỏ) → HM-QA PASS/FAIL → HM-Lead xin anh Năng merge → HM-Audit dọn → HM-Feedback gom phản hồi.
- Spec lệch nhau (SWE vs QA): HM-Lead hỏi HM-Design chốt, rồi ghi con số vào mục 4.
- Giao việc bằng file: `/workspace/hm-ui/simplify/handoff/dot-N.md` (commit SHA, đã sửa gì, cần test gì, dữ liệu test). Không dựa vào lịch sử chat.
- Hỏi anh Năng trước khi: merge, deploy production, xoá dữ liệu, đổi schema Supabase, gửi gì ra ngoài. Merge vào main = tự deploy web (deploy-pages).
- Cursor: luôn dùng model Auto.

## 2. Tiết kiệm token
- Lỗi HM-QA báo FAIL: HM-SWE PHẢI viết test tái hiện (widget/unit) trước, sửa đến khi test đạt, ghi tên test trong handoff. Không có test chặn lỗi thì không push.
- Trước khi push, HM-SWE tự chạy app, chụp ảnh và đo đúng chỗ bị FAIL, đính ảnh trong handoff. Thiếu ảnh thì HM-Lead không chuyển HM-QA.
- Lỗi lặp lại lần 2: HM-SWE ghi nguyên nhân gốc vào handoff trước khi sửa.
- Spec có 2 con số mâu thuẫn: HM-Lead hỏi HM-Design chốt ngay vòng đầu.
- HM-Lead đếm số vòng QA mỗi đợt; quá 2 vòng thì báo anh Năng kèm lý do.
- Chỉ đọc file phiếu nêu, không quét cả repo.
- Mỗi đợt 1 PR nhỏ, đúng phạm vi, không refactor thêm.
- Báo cáo ngắn: link PR, file đổi, cách chạy.
- Lỗi build sửa tối đa 2 lần rồi báo HM-Lead.

## 3. Quyết định đã chốt
- HomeManager = app tài chính gia đình. Không đổi schema (ngoại lệ duy nhất: mã mời 6 ký tự, đã duyệt).
- Đợt 1: Chi tiêu + chia tiền (chỉ xem), Cần trả tháng này, Tài sản ròng. Giữ màn Thu nhập riêng. Xoá 3 file không dùng.
- Spec 9 điểm (proposal.md) đã duyệt: thanh dưới = Tổng quan, Sổ giao dịch, (+), Cần trả, Tài sản; Cá nhân lên avatar; bỏ tab Thông báo; Tổng quan 3 thẻ; Ví/Tiết kiệm vào Tài sản; Chi tiêu theo tháng; hạn điện/nước theo ngày nhắc tháng sau.
- Spec gốc: `/workspace/hm-ui/simplify/proposal.md`, phiếu: `/workspace/hm-ui/simplify/tickets/dot-0..5.md`.

- 09/11 17:26 anh Năng duyệt: ô Ví trong form Thêm chi tiêu (Đợt 2) mặc định là ví dùng gần nhất, có lựa chọn 'Không trừ ví'. Câu báo link mời 'Bạn được mời vào một nhà. Đăng nhập hoặc tạo tài khoản để vào nhà.' làm PR riêng. Lịch sử ví hiện chi/hoàn tiền ở Đợt 4 (HM-Design chốt).

## 4. Con số spec dùng chung (theo trường hợp)
Khung 393×852 (iPhone 15 webview), an toàn trên 59 / dưới 34. Nội dung dài quá y 754 thì cuộn. Nguồn chi tiết: `proposal.md` và các phiếu.
| Thành phần | Trường hợp | Giá trị |
|---|---|---|
| Font | mọi chữ | Nunito (luôn set fontFamily). Cỡ: 32/40 w800 hero · 28/36 w800 · 22/28 w700 AppBar · 20/28 w800 · 18/24 w700 sheet · 16/24 w700 tiêu đề mục/nút · 14/20 w600 · 12/16 · 11/16 nhãn thanh dưới |
| Nút | tắt (chưa đủ điều kiện) | opacity 38% |
| Nút loading | đang gửi | onPressed: null, nền accent alpha 0.6 (không nhân thêm 38%); vòng quay 20, nét 2.5, cách chữ 8 |
| Toast | chung | 361×48, x 16–377, r12, nền #0F172A, icon 20 #7DD3A0 cách chữ 8, chữ 14 w600 trắng; nút hành động 14 w700 #FDBA74, vùng chạm 48; có nút hành động thì hiện 5 giây |
| Toast | màn CÓ thanh dưới | đáy toast cách mép trên thanh dưới 8px. Đợt 0 (thanh top 780): y 724–772. Từ Đợt 1 (thanh top 754): y 698–746. QA đo kết quả; cách code (margin) do SWE chọn |
| Toast | màn KHÔNG có thanh dưới | y 754–802 (cách đáy 50px) |
| Thanh dưới | Đợt 0 | top 780, cao 72 (nav cũ) |
| Thanh dưới | từ Đợt 1 | y 754–852 (64 + 34), viền trên 1; mục 78–79 × 64; pill 48×28 (y 763–791); nhãn 11/16 |
| Ô nhập mã/link mời | — | maxLength 512 (link ~96 ký tự) |
| Màu | — | accent #9A4507; chữ #0F172A / #475569 / #5B6B7F; lỗi #C81E1E; thành công #147038; cảnh báo #8F5606; viền #D1D9E6; nền trang #F5F6F8; card #FFFFFF; ô xám #EEF1F5; tint = màu × 0.12 (lỗi, thành công × 0.10) |
| Badge thẻ ngân hàng | — | neutral |
| Sai số đo | QA | ±3px |
| Component khác | — | xem mục Bảng component trong `/workspace/hm-ui/simplify/tickets/dot-1.md` |

## 5. Supabase production (project uvrfmotmimimtngzmccs)
| Migration | Version | Nội dung |
|---|---|---|
| invite_code | 20261109081406 | cột home_join_links.code, bảng invite_code_attempts, RPC mã mời |
| invite_code_hardening | 20261109081951 | revoke anon; generate_invite_code search_path = public, extensions, pg_temp |
| accept_invite_code_status | 20261109084619 | accept_invite_code trả jsonb {status: ok\|invalid\|locked}, khoá 5 lần sai/15 phút |
- Lưu ý: pgcrypto nằm ở schema `extensions` → hàm nào pin search_path mà dùng gen_random_bytes phải có `extensions`.
- Không sửa file migration đã áp; luôn tạo file mới.
- Tồn đọng (chưa làm): invite_code_attempts chưa có policy (INFO); nhiều RPC cũ còn WARN anon EXECUTE → HM-Audit rà sau.

- 20261109100536 revoke_anon_execute_legacy_rpcs (09/11 17:05, anh Năng duyệt): thu EXECUTE của anon/public trên 20 RPC cũ, GRANT lại authenticated + service_role; revoke all invite_code_attempts từ anon/authenticated. Kiểm: anon 0/20, authenticated 20/20. File: simplify/migrations/revoke_anon_execute_legacy_rpcs.sql. Hoàn tác: grant execute ... to anon.
- Advisors còn: cảnh báo 'authenticated chạy SECURITY DEFINER' (cố ý), invite_code_attempts không policy (cố ý, deny-all), leaked password protection chưa bật.

## 6. Dữ liệu test trên production (giữ lại, dùng tiếp cho Đợt 1)
- Chỉ dùng 1 database (production), KHÔNG tạo project test (anh Năng chốt 09/11). Dữ liệu test luôn có tiền tố hmtest/TEST; dọn sau mỗi đợt khi anh duyệt. Migration chỉ áp sau khi HM-QA duyệt code và anh Năng đồng ý.
- 4 tài khoản phamchinang.vn+hmtest-{owner,join,join2,join3}-20261109@gmail.com (đều đã có nhà).
- Nhà 'TEST Đợt 0 QA' id 149f6029-f7f7-45ca-8b15-cdedea6a47ba; mã FVG7DV (hết hạn 23/11) + 1 link mời.
- Test lại: chỉ giả lập phản hồi, KHÔNG tạo thêm tài khoản (anh Năng chốt 09/11).
- Ví 'TEST ví' 100.000đ (id 932fd98f-…) do HM-QA tạo 09/11 17:2x khi smoke test, lịch sử có 3 dòng điều chỉnh.
- Anh Năng chốt 09/11 16:54: GIỮ dữ liệu test để Đợt 1 dùng tiếp. Chỉ dọn khi anh duyệt lại. Không tạo thêm tài khoản.

## 7. Trạng thái các đợt
| Đợt | PR | Trạng thái |
|---|---|---|
| 0 – Mã mời + màn Chưa có nhà | [#9](https://github.com/PhamChiNang151020/home-manager/pull/9) @ e01c44b | ĐÃ MERGE 09/11 (squash c2d9fff), QA PASS, 4 vòng QA. |
| 1 – Điều hướng mới | — | Đang làm (HM-SWE), ticket simplify/tickets/dot-1.md, base main @ c2d9fff |
| 2–5 | — | Chưa bắt đầu, làm lần lượt |

## 8. Ghi chú để sau (không thuộc Đợt 0)
- Câu gợi ý ghi 'Cá nhân → Thành viên' nhưng menu tên 'Chia sẻ'.
- Sau khi tạo tài khoản, màn đứng yên tới khi tải lại trang.
- Toast: HM-Design chốt 09/11, không có nút thì hiện 2,6s, có nút hành động thì 5s (chạm nút thì ẩn ngay). Đã khớp mục 4.
- _scaffoldHasBottomNav duyệt cả cây element mỗi lần hiện toast: HM-Audit xem lại.
- Nút (+) thêm chi tiêu không chọn được ví (quick_add_picker_sheet.dart:96-117), phải vào sửa mới chọn: chờ HM-Design chốt cố ý hay thiếu.
- Thanh toán chi tiêu từ ví và hoàn tiền không hiện trong lịch sử ví.
- Mở link ?join= khi chưa đăng nhập, màn đăng nhập không báo là đang được mời vào nhà.

- 09/11 17:57 (HM-Design chốt, PR #11): banner mời ngắt dòng tự nhiên ("…một nhà. Đăng" / "nhập hoặc tạo…"). Giữ số: ô chữ 253, Nunito 14/20 w600, đúng 2 dòng, cao 64. Không dùng nbsp. QA chỉ kiểm 2 dòng + cao 64, không kiểm chỗ ngắt.
- 09/11 17:59 (HM-Design chốt, Đợt 1): vùng an toàn dưới theo môi trường. Web (inset 0): nav y 788–852, nút + 797–845, toast 732–780. Máy inset 34: nav 754–852, nút + 763–811, toast 698–746. Đo theo cạnh dưới viewport, toast cách nav 8, sai số ±3. Nguồn: tickets/dot-1.md mục "Vùng an toàn dưới theo môi trường".
- 09/11 18:13 (HM-Design chốt sau QA vòng 1 Đợt 1): Tài sản = Ví · Tiết kiệm · Tín dụng NH · Nợ vay mượn (dòng 64, icon savings vòng 36). Sheet Thêm nhanh đáy = 16 + viewPadding.bottom (web 348–852, iPhone 314–852). Tiêu đề Cá nhân x 72 (AppBar mặc định). Biểu đồ Đợt 1 giữ bản cũ (card 224, tiêu đề trong card), kiểu app-v2 để Đợt 5. Web inset trên 0, mọi phần tử trên cao hơn iPhone 59, không tính lỗi.
- 09/11 18:41: PR #11 MERGED (squash 9a8373d, 2 vòng QA, deploy success). Đợt 1 PR #10 MERGED (squash 778464a, 2 vòng QA), deploy run 42611119994. Tồn: màn Ví còn trang Tài sản cũ (trùng Tín dụng/Nợ) → HM-Design xếp đợt sau.
- 09/11 18:46: Audit Đợt 1 (simplify/audit/dot-1.md): không có mục chặn. Còn tồn cho PR dọn riêng: string chết S.notifications + 5 S.tab*; 4 file test hardcode /opt/cursor/artifacts; tool/dot1_nav_web_demo.dart. Màn Ví bỏ 2 section Tín dụng/Nợ → HM-Design xếp đợt. Giữ NotificationsPage cho Đợt 3.
- 09/11 18:47 (HM-Design): gỡ Tín dụng/Nợ khỏi màn Ví → Đợt 4 (dot-4.md mục 5 "Bổ sung 09/11: Màn Ví chỉ còn ví"). Ví chỉ còn card Tổng số dư, mục Ví + "+ Thêm ví" + danh sách. Không đổi chữ/luồng.

## Redesign nền tối (anh Năng duyệt 09/11 19:42)
- Phạm vi: tất cả màn, kể cả đăng nhập + cài đặt. Tông nền tối. Đổi schema: hỏi anh từng lần.
- Nhánh `redesign` (tách từ main mới nhất); mỗi PR 1–2 màn nhắm vào redesign, QA từng PR; cuối cùng merge redesign → main 1 lần (hỏi anh).
- Rule: (1) HM-Design làm token (màu/chữ/khoảng cách) + ảnh mẫu tất cả màn, anh duyệt xong mới code; (2) spec phải được đo thử trên khung 393×852 trước khi giao SWE; (3) SWE và QA chung lệnh test (`flutter test`, không có /opt/cursor/artifacts) + Flutter 3.29.2, handoff dán nguyên dòng kết quả; (4) màu/khoảng cách ngoài token thì trả PR; (5) mỗi PR 1–2 màn; (6) HM-Lead soát ảnh handoff so spec trước khi chuyển QA.
- 09/11 19:53: anh Năng duyệt hướng nền tối. Token ở /workspace/hm-ui/redesign/tokens.md, mọi cặp màu đạt WCAG AA. Cam thương hiệu: chữ/icon #FB9F5A, nút chính #F28C40 với chữ tối #1A0D03.
- 09/11 19:53: đăng nhập bỏ thẻ trắng, nội dung cột 361 đặt thẳng trên nền; banner mời cũng 361.
- 09/11 19:53: app chỉ có nền tối, bỏ lựa chọn Sáng/Tối/Hệ thống. Nếu màn Giao diện trống thì đề xuất bỏ hẳn mục này (chờ anh duyệt cùng index).
- Mọi số trong spec và ảnh mẫu đo trên khung 393×852 bằng Nunito thật, kèm measure.json và bước kiểm tra chữ tràn.
