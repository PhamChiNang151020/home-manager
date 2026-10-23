CSS="""
@font-face{font-family:N;src:url(Nunito-Regular.ttf);font-weight:400}
@font-face{font-family:N;src:url(Nunito-SemiBold.ttf);font-weight:600}
@font-face{font-family:N;src:url(Nunito-Bold.ttf);font-weight:700}
*{box-sizing:border-box;margin:0}body{width:390px;height:844px;font-family:N;background:linear-gradient(#F5F6F8,#FFFFFF);display:flex;align-items:center;justify-content:center;color:#0F172A}
.card{width:310px;padding:24px;border-radius:16px;background:linear-gradient(135deg,#FFFFFF,#FAFAFB);border:1px solid rgba(255,255,255,.35);box-shadow:0 4px 10px rgba(15,23,42,.08);display:flex;flex-direction:column}
.logo{width:64px;height:64px;align-self:center}.t{font-size:28px;line-height:36px;font-weight:400;text-align:center;margin-top:16px}
.tag{font-size:14px;line-height:20px;font-weight:600;color:#475569;text-align:center;margin-top:4px}
.hint{font-size:14px;line-height:20px;color:#475569;text-align:center;margin-top:8px}
.h2{font-size:22px;line-height:28px;font-weight:700;text-align:center;margin-top:16px}
label{font-size:12px;line-height:16px;font-weight:600;color:#475569;margin-bottom:4px;display:block}
.f{margin-top:16px}.in{height:48px;border:1px solid #D1D9E6;border-radius:12px;padding:0 16px;display:flex;align-items:center;font-size:14px;background:#fff;justify-content:space-between}
.in.ph{color:#5B6B7F}.in.focus{border:1.5px solid #9A4507}.in.err{border:1.5px solid #C81E1E}
.eye{width:48px;height:48px;margin-right:-16px;display:flex;align-items:center;justify-content:center;color:#475569}
.msg{min-height:16px;font-size:12px;line-height:16px;margin-top:4px;color:#C81E1E}
.btn{height:48px;border-radius:12px;display:flex;align-items:center;justify-content:center;gap:8px;font-size:14px;font-weight:600}
.pri{background:#9A4507;color:#fff;margin-top:8px}.pri.load{opacity:.85}
.out{border:1px solid #D1D9E6;color:#0F172A;background:#fff}
.link{height:48px;display:flex;align-items:center;color:#9A4507;font-size:14px;font-weight:600}
.or{display:flex;align-items:center;gap:12px;color:#5B6B7F;font-size:12px;height:40px}.or:before,.or:after{content:"";flex:1;height:1px;background:#D1D9E6}
.foot{display:flex;justify-content:center;align-items:center;font-size:14px;color:#475569;gap:4px;margin-top:8px}
.back{height:48px;display:flex;align-items:center;gap:4px;color:#9A4507;font-weight:600;font-size:14px;margin:-8px 0 0 -8px;padding-left:8px}
.spin{width:18px;height:18px;border:2px solid rgba(255,255,255,.4);border-top-color:#fff;border-radius:50%}
.ic{width:56px;height:56px;border-radius:50%;background:rgba(154,69,7,.12);color:#9A4507;align-self:center;display:flex;align-items:center;justify-content:center;font-size:28px;margin-top:8px}
.em{font-weight:700;color:#0F172A}
"""
EYE='<span class="eye"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-7 11-7 11 7 11 7-4 7-11 7S1 12 1 12z"/><circle cx="12" cy="12" r="3"/></svg></span>'
G='<svg width="18" height="18" viewBox="0 0 48 48"><path fill="#EA4335" d="M24 9.5c3.5 0 6.6 1.2 9 3.5l6.7-6.7C35.6 2.4 30.2 0 24 0 14.6 0 6.6 5.4 2.6 13.2l7.8 6C12.3 13.6 17.6 9.5 24 9.5z"/><path fill="#4285F4" d="M46.1 24.6c0-1.6-.1-3.1-.4-4.6H24v9h12.4c-.5 2.9-2.2 5.3-4.6 6.9l7.4 5.8c4.3-4 6.9-9.9 6.9-17.1z"/><path fill="#FBBC05" d="M10.4 28.8c-.5-1.4-.8-3-.8-4.8s.3-3.3.8-4.8l-7.8-6C.9 16.5 0 20.1 0 24s.9 7.5 2.6 10.8l7.8-6z"/><path fill="#34A853" d="M24 48c6.5 0 11.9-2.1 15.9-5.8l-7.4-5.8c-2.1 1.4-4.8 2.3-8.5 2.3-6.4 0-11.7-4.1-13.6-9.7l-7.8 6C6.6 42.6 14.6 48 24 48z"/></svg>'
def field(lbl,val,ph=True,cls="",msg="",eye=False):
    return f'<div class="f"><label>{lbl}</label><div class="in {"ph" if ph else ""} {cls}"><span>{val}</span>{EYE if eye else ""}</div><div class="msg">{msg}</div></div>'
HEAD='<img class="logo" src="logo.png"><div class="t">Tổ Ấm</div><div class="tag">Giữ ấm tổ ấm, giữ vững chi tiêu</div>'
def login(e=("Email@ví dụ: ban@email.com",True,"",""),p=("••••••••",False,"",""),btn='Đăng nhập'):
    return HEAD+'<div class="hint">Đăng nhập để đồng bộ dữ liệu với gia đình.</div>'+field("Email",e[0].split("@",1)[1] if e[0].startswith("Email@") else e[0],e[1],e[2],e[3])+field("Mật khẩu",p[0],p[1],p[2],p[3],True)+\
     '<div style="display:flex;justify-content:flex-end;margin-top:-12px"><span class="link">Quên mật khẩu?</span></div>'+\
     f'<div class="btn pri {"load" if btn!="Đăng nhập" else ""}">{btn}</div><div class="or">hoặc</div><div class="btn out">{G}Đăng nhập bằng Google</div>'+\
     '<div class="foot">Chưa có tài khoản?<span class="link">Tạo tài khoản</span></div>'
E="ban@email.com"
BK='<div class="back">‹ Đăng nhập</div>'
def su(p=("Ít nhất 8 ký tự",True,"",""),c=("Nhập lại mật khẩu",True,"",""),e=("ban@email.com",True,"","")):
    return BK+HEAD+'<div class="h2" style="font-size:20px">Tạo tài khoản</div>'+field("Email",*e)+field("Mật khẩu",*p,True)+field("Nhập lại mật khẩu",*c,True)+'<div class="btn pri">Tạo tài khoản</div><div class="foot">Đã có tài khoản?<span class="link">Đăng nhập</span></div>'
def npw(p=("Ít nhất 8 ký tự",True,"",""),c=("Nhập lại mật khẩu mới",True,"","")):
    return HEAD+'<div class="h2" style="font-size:20px">Đặt mật khẩu mới</div><div class="hint">Cho tài khoản <span class="em">ban@email.com</span></div>'+field("Mật khẩu mới",*p,True)+field("Nhập lại",*c,True)+'<div class="btn pri">Đặt mật khẩu</div>'
D="••••••••";W="Email hoặc mật khẩu chưa đúng."
S={
"01-dang-nhap-mac-dinh":login(),
"02-dang-nhap-loi-email":login(e=("ban@email",False,"err","Email chưa đúng định dạng.")),
"03-dang-nhap-sai-thong-tin":login(e=(E,False,"",""),p=(D,False,"err",W)),
"04-dang-nhap-dang-tai":login(e=(E,False,"",""),btn='<span class="spin"></span>Đang đăng nhập…'),
"05-tao-tai-khoan":su(),
"06-tao-tai-khoan-loi-email-da-co":su(e=(E,False,"err","Email này đã có tài khoản. Hãy đăng nhập."),p=(D,False,"",""),c=(D,False,"","")),
"07-tao-tai-khoan-loi-mat-khau-ngan":su(e=(E,False,"",""),p=("•••••",False,"err","Mật khẩu cần ít nhất 8 ký tự."),c=("•••••",False,"","")),
"08-tao-tai-khoan-loi-khong-khop":su(e=(E,False,"",""),p=(D,False,"",""),c=("•••••••",False,"err","Hai mật khẩu chưa khớp.")),
"09-quen-mat-khau":BK+HEAD+'<div class="h2" style="font-size:20px">Quên mật khẩu</div><div class="hint">Nhập email đã dùng để tạo tài khoản. Mình sẽ gửi link đặt lại mật khẩu.</div>'+field("Email","ban@email.com",cls="focus")+'<div class="btn pri">Gửi link đặt lại</div>',
"10-quen-mat-khau-da-gui":'<div class="ic">✓</div><div class="h2">Đã gửi link</div>'+f'<div class="hint">Nếu <span class="em">{E}</span> có tài khoản Tổ Ấm, link đặt lại mật khẩu sẽ tới trong vài phút.</div><div class="btn pri" style="margin-top:24px">Về Đăng nhập</div>',
"11-dat-mat-khau-moi":npw(),
"12-dat-mat-khau-moi-loi-ngan":npw(p=("•••••",False,"err","Mật khẩu cần ít nhất 8 ký tự."),c=("•••••",False,"","")),
"13-dat-mat-khau-moi-loi-khong-khop":npw(p=(D,False,"",""),c=("•••••••",False,"err","Hai mật khẩu chưa khớp.")),
}
for k,v in S.items(): open(k+".html","w").write(f'<html><head><meta charset=utf-8><style>{CSS}</style></head><body><div class="card">{v}</div></body></html>')
