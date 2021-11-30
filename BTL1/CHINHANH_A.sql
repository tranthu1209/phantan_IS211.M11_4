------------------------- Tại MÁY A ---------------------------------
-- 1. Trên SQL Plus đăng nhập /as sysdba, sau đó tạo user để insert DL
----- 1.1 Tạo một user CNA với password là CNA
CREATE USER CNA IDENTIFIED BY CNA;

----- 1.2 Gán quyền connect, dba cho tài khoản CNA
GRANT CONNECT, DBA TO CNA;

-------------------------------------------------------------------------------
-- 2. Mở SQL Dev, tạo connect CHI NHANH A dùng user CNA
----- 2.1 Chạy lệnh tạo bảng
CREATE TABLE CNA.LOAIPHONG
(
	MALP char(3) PRIMARY KEY,
	TENLP varchar2 (40) NOT NULL,
	TRANGBI varchar2(100) NOT NULL,
	GIA number NOT NULL
);

CREATE TABLE CNA.CHINHANH(
	MACN char(3) PRIMARY KEY, 
	TENCN varchar2(30) NOT NULL,
    DIACHI varchar2(80) NOT NULL,
	SDT char(10) NOT NULL UNIQUE
);

CREATE TABLE CNA.PHONG
(
	MAPHONG char(5) PRIMARY KEY, 
	TENPHONG varchar2(30) NOT NULL,
	TINHTRANG varchar2(20) NOT NULL,
	MALP char(3) REFERENCES CNA.LOAIPHONG(MALP),
	MACN char(3) REFERENCES CNA.CHINHANH(MACN)
);

CREATE TABLE CNA.CHUCVU(
	MACV char(2) PRIMARY KEY, 
	TENCV varchar2(30) NOT NULL
);

CREATE TABLE CNA.NHANVIEN(
	MANV char(4) PRIMARY KEY,
	TENNV varchar2(40) NOT NULL,
	MACV char(2) REFERENCES CNA.CHUCVU(MACV),
	GIOITINH varchar2(6) NOT NULL,
	NGAYSINH date NOT NULL,
	DIACHI varchar2(200) NOT NULL, 
	SDT varchar(10) NOT NULL UNIQUE,
	MACN char(3) REFERENCES CNA.CHINHANH(MACN) 
);

CREATE TABLE CNA.KHACHHANG(
	MAKH char(4) PRIMARY KEY,
	TENKH varchar2(40) NOT NULL,
	DIACHI varchar2(200), 
	GIOITINH varchar2(6) NOT NULL,
	CMND char(9) NOT NULL,
	SDT varchar2(10) NOT NULL UNIQUE,
	QUOCTICH varchar2(30),
    MACN char(3) REFERENCES CNA.CHINHANH(MACN)
);

CREATE TABLE CNA.PHIEU_DK_P(
	MAPDK char(5) PRIMARY KEY,
	MAKH char(4) REFERENCES CNA.KHACHHANG(MAKH),
	MANV char(4) REFERENCES CNA.NHANVIEN(MANV),
	NGAYDK_P date NOT NULL,
	MAPHONG	char(5) REFERENCES CNA.PHONG(MAPHONG),
	MACN char(3) REFERENCES CNA.CHINHANH(MACN)
);

CREATE TABLE CNA.DICHVU(
	MADV char(4) PRIMARY KEY,
	TENDV varchar2(50) NOT NULL,
	PHIDV number NOT NULL
);

CREATE TABLE CNA.DK_DV(
    MADK_DV char(7) PRIMARY KEY,
	MADV char(4) REFERENCES CNA.DICHVU(MADV),
	MAPDK char(5) REFERENCES CNA.PHIEU_DK_P(MAPDK),
	NGAYDK_DV date NOT NULL,
    MACN char(3) REFERENCES CNA.CHINHANH(MACN)
);

CREATE TABLE CNA.HOADON_QL(
	MAHD char(4) PRIMARY KEY,
	NGAYTHANHTOAN date NOT NULL,
	DANHGIA number NOT NULL,
	MANV char(4) REFERENCES CNA.NHANVIEN(MANV),
	MAPDK char(5) REFERENCES CNA.PHIEU_DK_P(MAPDK),
	MACN char(3) REFERENCES CNA.CHINHANH(MACN)
);

CREATE TABLE CNA.HOADON_NV(
	MAHD char(4) PRIMARY KEY,
	NGAYTHANHTOAN date NOT NULL,
	SONGAY number NOT NULL, 
	TONGTIEN number NOT NULL,
	MANV char(4) REFERENCES CNA.NHANVIEN(MANV),
	MAKH char(4) REFERENCES CNA.KHACHHANG(MAKH),
	MAPDK char(5) REFERENCES CNA.PHIEU_DK_P(MAPDK),
	MACN char(3) REFERENCES CNA.CHINHANH(MACN)
);

-------------------------------------------------------------------------------
----- 2.2 Chạy các Trigger (lƯU Ý: chạy lệnh tạo lần lượt từng trigger)
-- Trigger: Ngày đăng ký dịch vụ không được trước ngày đăng ký phòng 
--          NGAYDK_DV >= NGAYDK_P

/*
- Bối cảnh: PHIEU_DK_P, DK_DV

- Nội dung: Với mọi pdk_p thuộc PHIEU_DK_P, tồn tại dk_dv thuộc DK_DV: 
    pdk_p.MAPDK = dk_dv.MAPDK và NGAYDK_DV >= NGAYDK_P 
                
- Bảng tầm ảnh hưởng:
          Thêm	 Xóa	Sửa
DK_DV	    +	  -	     +(NGAYDK_DV, MAPDK)
PHIEU_DK_P  -	  -	     +(NGAYDK_P)

*/
-- Trigger INSERT, UPDATE trên bảng DK_DV
CREATE OR REPLACE TRIGGER INSERT_UPDATE_DK_DV
AFTER INSERT OR UPDATE
ON CNA.DK_DV FOR EACH ROW
DECLARE
    v_ngaydk_p DATE;
BEGIN
    SELECT NGAYDK_P INTO v_ngaydk_p
    FROM CNA.PHIEU_DK_P PDK_P
    WHERE PDK_P.MAPDK = :NEW.MAPDK;
    
    IF (:NEW.NGAYDK_DV < v_ngaydk_p) THEN
        RAISE_APPLICATION_ERROR(-20100, 'Ngày đăng ký dịch vụ không được 
            trước ngày đăng ký phòng');
    END IF;    
END;

-------------------------------------------
-- Trigger UPDATE trên bảng PHIEU_DK_P
CREATE OR REPLACE TRIGGER UPDATE_DK_P
AFTER UPDATE
ON CNA.PHIEU_DK_P FOR EACH ROW
DECLARE
    v_ngaydk_dv DATE;
BEGIN
    SELECT NGAYDK_DV INTO v_ngaydk_dv
    FROM CNA.DK_DV DK_DV
    WHERE DK_DV.MAPDK = :NEW.MAPDK;
    
    IF (:NEW.NGAYDK_P > v_ngaydk_dv) THEN
        RAISE_APPLICATION_ERROR(-20100, 'Ngày đăng ký dịch vụ không được 
            trước ngày đăng ký phòng');
    END IF;    
END;

---------------------------------------
-- Trigger: SONGAY = NGAYTHANHTOAN - NGAYDK_P

/*
- Bối cảnh: PHIEU_DK_P, HOADON_NV

- Nội dung: Với mọi pdk_p thuộc PHIEU_DK_P, tồn tại hd_nv thuộc HOADON_NV: 
    pdk_p.MAPDK = hd_nv.MAPDK và SONGAY = NGAYTHANHTOAN - NGAYDK_P
                
- Bảng tầm ảnh hưởng:
          Thêm	 Xóa	Sửa
HOADON_NV	+	  -	     +(NGAYTHANHTOAN, SONGAY, MAPDK)
PHIEU_DK_P  -	  -	     +(NGAYDK_P)

*/
-- Trigger INSERT, UPDATE trên bảng HOADON_NV
CREATE OR REPLACE TRIGGER INSERT_UPDATE_HOADON_NV_SN
AFTER INSERT OR UPDATE
ON CNA.HOADON_NV FOR EACH ROW
DECLARE
    v_ngaydk_p DATE;
BEGIN
    SELECT NGAYDK_P INTO v_ngaydk_p
    FROM CNA.PHIEU_DK_P PDK_P
    WHERE PDK_P.MAPDK = :NEW.MAPDK;
    
    IF (:NEW.SONGAY != :NEW.NGAYTHANHTOAN - v_ngaydk_p) THEN
        RAISE_APPLICATION_ERROR(-20102, 'Số ngày đã bị tính sai');
    END IF;    
END;

---------------------------------------
-- Trigger UPDATE trên bảng PHIEU_DK_P
CREATE OR REPLACE TRIGGER UPDATE_DK_P_TT
AFTER UPDATE
ON CNA.PHIEU_DK_P FOR EACH ROW
DECLARE
    v_ngaythanhtoan DATE;
    v_songay number;
BEGIN
    SELECT NGAYTHANHTOAN INTO v_ngaythanhtoan
    FROM CNA.HOADON_NV HD_NV
    WHERE HD_NV.MAPDK = :NEW.MAPDK;
    
    IF (v_songay != v_ngaythanhtoan - :NEW.NGAYDK_P) THEN
        RAISE_APPLICATION_ERROR(-20102, 'Số ngày đã bị tính sai');
    END IF;     
END;

--------------------------------------
-- Trigger: TONGTIEN = SONGAY*GIA + SUM(PHIDV)

-- Trigger INSERT, UPDATE trên bảng HOADON_NV
CREATE OR REPLACE TRIGGER INSERT_UPDATE_HOADON_NV_TT
AFTER INSERT OR UPDATE
ON CNA.HOADON_NV FOR EACH ROW
DECLARE
    v_sum_phidv NUMBER;
    v_gia_P NUMBER;
BEGIN
    SELECT SUM(PHIDV) INTO v_sum_phidv
    FROM CNA.DK_DV DK_DV, CNA.DICHVU DIV
    WHERE DK_DV.MAPDK = :NEW.MAPDK AND DK_DV.MADV = DIV.MADV
    GROUP BY :NEW.MAPDK;
    
    SELECT GIA*:NEW.SONGAY INTO  v_gia_P
    FROM CNA.LOAIPHONG LP, CNA.PHONG P, CNA.PHIEU_DK_P PDK
    WHERE LP.MALP = P.MALP AND P.MAPHONG = PDK.MAPHONG
            AND PDK.MAPDK = :NEW.MAPDK;
    
    IF (:NEW.TONGTIEN != v_gia_P + v_sum_phidv) THEN
        RAISE_APPLICATION_ERROR(-20102, 'Tổng tiền đã bị tính sai');
    END IF; 
END;

-------------------------------------------------------------------------------
----- 2.3 Chạy lệnh Insert DL
ALTER SESSION SET NLS_DATE_FORMAT = ' DD/MM/YYYY HH24:MI:SS ';

----Insert dữ liệu vào table LOAIPHONG
insert into CNA.LOAIPHONG values ('LP1','PHÒNG VIP1','TIVI, TỦ LẠNH, ĐIỀU HÒA, 
GIƯỜNG VIP1, WIFI, MÁY NƯỚC NÓNG',700000);
insert into CNA.LOAIPHONG values ('LP2','PHÒNG VIP2','TIVI, TỦ LẠNH, ĐIỀU HÒA, 
GIƯỜNG VIP2, WIFI',600000);
insert into CNA.LOAIPHONG values ('LP3','PHÒNG THƯỜNG','TIVI, WIFI, GIƯỜNG',
        400000);

----Insert dữ liệu vào table CHINHANH
insert into CNA.CHINHANH values ('CNA','Chi nhánh Thủ Đức','TP Thủ Đức, TP HCM','0939013321');

----Insert dữ liệu vào table PHONG
insert into CNA.PHONG values ('PA001','PHÒNG A001','ĐANG SỬ DỤNG','LP1','CNA');
insert into CNA.PHONG values ('PA002','PHÒNG A002','ĐANG SỬ DỤNG','LP1','CNA');
insert into CNA.PHONG values ('PA003','PHÒNG A003','TRỐNG','LP1','CNA');
insert into CNA.PHONG values ('PA004','PHÒNG A004','TRỐNG','LP1','CNA');
insert into CNA.PHONG values ('PA005','PHÒNG A005','TRỐNG','LP1','CNA');
insert into CNA.PHONG values ('PA006','PHÒNG A006','TRỐNG','LP1','CNA');
insert into CNA.PHONG values ('PA007','PHÒNG A007','TRỐNG','LP1','CNA');
insert into CNA.PHONG values ('PA008','PHÒNG A008','ĐANG SỬ DỤNG','LP1','CNA');
insert into CNA.PHONG values ('PA009','PHÒNG A009','ĐANG SỬ DỤNG','LP1','CNA');
insert into CNA.PHONG values ('PA010','PHÒNG A010','ĐANG SỬ DỤNG','LP1','CNA');
insert into CNA.PHONG values ('PA011','PHÒNG A011','ĐANG SỬ DỤNG','LP2','CNA');
insert into CNA.PHONG values ('PA012','PHÒNG A012','ĐANG SỬ DỤNG','LP2','CNA');
insert into CNA.PHONG values ('PA013','PHÒNG A013','TRỐNG','LP2','CNA');
insert into CNA.PHONG values ('PA014','PHÒNG A014','TRỐNG','LP2','CNA');
insert into CNA.PHONG values ('PA015','PHÒNG A015','TRỐNG','LP2','CNA');
insert into CNA.PHONG values ('PA016','PHÒNG A016','TRỐNG','LP2','CNA');
insert into CNA.PHONG values ('PA017','PHÒNG A017','TRỐNG','LP2','CNA');
insert into CNA.PHONG values ('PA018','PHÒNG A018','TRỐNG','LP2','CNA');
insert into CNA.PHONG values ('PA019','PHÒNG A019','ĐANG SỬ DỤNG','LP2','CNA');
insert into CNA.PHONG values ('PA020','PHÒNG A020','ĐANG SỬ DỤNG','LP2','CNA');
insert into CNA.PHONG values ('PA021','PHÒNG A021','TRỐNG','LP3','CNA');
insert into CNA.PHONG values ('PA022','PHÒNG A022','TRỐNG','LP3','CNA');
insert into CNA.PHONG values ('PA023','PHÒNG A023','TRỐNG','LP3','CNA');
insert into CNA.PHONG values ('PA024','PHÒNG A024','TRỐNG','LP3','CNA');
insert into CNA.PHONG values ('PA025','PHÒNG A025','ĐANG SỬ DỤNG','LP3','CNA');
insert into CNA.PHONG values ('PA026','PHÒNG A026','TRỐNG','LP3','CNA');
insert into CNA.PHONG values ('PA027','PHÒNG A027','TRỐNG','LP3','CNA');
insert into CNA.PHONG values ('PA028','PHÒNG A028','TRỐNG','LP3','CNA');
insert into CNA.PHONG values ('PA029','PHÒNG A029','TRỐNG','LP3','CNA');
insert into CNA.PHONG values ('PA030','PHÒNG A030','TRỐNG','LP3','CNA');

----Insert dữ liệu vào table CHUCVU
insert into CNA.CHUCVU values ('GD','GIÁM ĐỐC');
insert into CNA.CHUCVU values ('QL','QUẢN LÝ');
insert into CNA.CHUCVU values ('NV','NHÂN VIÊN');

----Insert dữ liệu vào table NHANVIEN
insert into CNA.NHANVIEN values('NV01','Nguyễn Anh Tuấn','GD','Nam','01/10/1986',
    '29/7A Trần Hữu Trang, Phường 11, Quận Phú Nhuận, TP Hồ Chí Minh','0715884274','CNA');
insert into CNA.NHANVIEN values('NV02','Hồ Văn Trí','QL','Nam','06/11/1986',
    'Lầu 5 Tòa nhà Tập đoàn FIT, Số 276 Nguyễn Đình Chiểu, Phường 06, Quận 3, TP Hồ Chí Minh','0696338439','CNA');
insert into CNA.NHANVIEN values('NV03','Nguyễn Thị Đào','NV','Nam','06/10/1987',
    '96/14 Khu Phố 4, Đường Tân Mỹ, Phường Tân Thuận Tây, Quận 7, TP Hồ Chí Minh','0594969363','CNA');
insert into CNA.NHANVIEN values('NV04','Lê Thanh Triệu','NV','Nam','06/05/1986',
    '40/40/4A Tô Hiệu, Phường Tân Thới Hoà, Quận Tân phú, TP Hồ Chí Minh','0835897558','CNA');
insert into CNA.NHANVIEN values('NV05','Lý Văn Đức','NV','Nam','25/12/1986',
    'Số 2 Đường 49, Phường Bình Trưng Đông, Quận 2, TP Hồ Chí Minh','0665193285','CNA');
insert into CNA.NHANVIEN values('NV06','Hồ Ngọc Chúc','NV','Nữ','06/01/1986',
    'Phòng số 2, Tòa nhà 6A, lô 6A, đường số 3, Công viên phần mề, phường Tân Chánh Hiệp, Quận 12, TP Hồ Chí Minh','0292632426','CNA');
insert into CNA.NHANVIEN values('NV07','Nguyễn Thị Nhạn','NV','Nam','23/10/1985',
    '15/4/20 Lê Lai, Phường 12, Quận Tân Bình, TP Hồ Chí Minh','0576843374','CNA');
insert into CNA.NHANVIEN values('NV08','Vũ Viết Tâm','NV','Nữ','30/10/1983',
    '95/26 Lê Văn Sỹ, Phường 13, Quận Phú Nhuận, TP Hồ Chí Minh','0635797651','CNA');
insert into CNA.NHANVIEN values('NV09','Lê Ngọc Sương','NV','Nữ','15/05/1987',
    '235/65 Nam Kỳ Khởi Nghĩa, Phường 07, Quận 3, TP Hồ Chí Minh','0634332766','CNA');
insert into CNA.NHANVIEN values('NV10','Lê Văn Thọ','NV','Nam','25/06/1989',
    '44A/27 Bùi Văn Ba, Phường Tân Thuận Đông, Quận 7, TP Hồ Chí Minh','0936382211','CNA');
insert into CNA.NHANVIEN values('NV11','Quách Thị Thanh','NV','Nữ','01/10/1986',
    'L7 Và L8, Tầng Lửng Lô B, Tòa Nhà Chung Cư Khánh Hội 01, Số, phường 01, Quận 4, TP Hồ Chí Minh','0173995882','CNA');
insert into CNA.NHANVIEN values('NV12','Hứa Ngọc Mỹ','NV','Nữ','06/11/1986',
    '25/1C Nguyễn Hậu, Phường Tân Thành, Quận Tân phú, TP Hồ Chí Minh','0362771822','CNA');
insert into CNA.NHANVIEN values('NV13','Nguyễn Tiến Dũng','NV','Nam','06/10/1987',
    '178/4B Pasteur, Phường Bến Nghé, Quận 1, TP Hồ Chí Minh','0227918759','CNA');
insert into CNA.NHANVIEN values('NV14','Nguyễn Văn Trình','NV','Nam','06/05/1986',
    '29 Đường Nội Khu Mỹ Toàn 2, Khu Đô Thị Phú Mỹ Hưng, Phường Tân Phong, Quận 7, TP Hồ Chí Minh','0556379741','CNA');
insert into CNA.NHANVIEN values('NV15','Đào Thị Mỹ Hồng','NV','Nữ','25/12/1986',
    '47/42/22A Bùi Đình Tuý, Phường 24, Quận Bình Thạnh, TP Hồ Chí Minh','0345323162','CNA');
insert into CNA.NHANVIEN values('NV16','Nguyễn Thị Ái Thuỷ','NV','Nữ','06/01/1986',
    '94 Lương Trúc Đàm, Phường Hiệp Tân, Quận Tân phú, TP Hồ Chí Minh','0837652688','CNA');
insert into CNA.NHANVIEN values('NV17','Trương Thị Thu Hương','NV','Nữ','23/10/1985',
    '484A Lê Văn Việt, Phường Tăng Nhơn Phú A, Quận 9, TP Hồ Chí Minh','0613493729','CNA');
insert into CNA.NHANVIEN values('NV18','Nguyễn Thị Bích Hằng','NV','Nữ','30/10/1983',
    'Lầu 8, Tòa nhà Mobivi, 104 Mai Thị Lựu, Phường Đa Kao, Quận 1, TP Hồ Chí Minh','0738375233','CNA');
insert into CNA.NHANVIEN values('NV19','Đoàn Thị Xuân Thảo','NV','Nữ','15/05/1987',
    '21/16 Xuân Thủy, Phường Thảo Điền, Quận 2, TP Hồ Chí Minh','0668679892','CNA');
insert into CNA.NHANVIEN values('NV20','Huỳnh Thị Nguyên','NV','Nữ','01/10/1986',
    '451/24/4 Tô Hiến Thành, Phường 14, Quận 10, TP Hồ Chí Minh','0584369979','CNA');
insert into CNA.NHANVIEN values('NV21','Nguyễn Văn Ngọc','NV','Nam','06/11/1986',
    'Tầng 21, Tòa nhà E.Town Central, Số 11 Đoàn Văn Bơ, phường 12, Quận 4, TP Hồ Chí Minh','0828657213','CNA');
insert into CNA.NHANVIEN values('NV22','Phan Văn Trang','NV','Nữ','06/10/1987',
    'Lầu 1, Tòa nhà H3, Số 384 Hoàng Diệu, phường 06, Quận 4, TP Hồ Chí Minh','0473614631','CNA');
insert into CNA.NHANVIEN values('NV23','Trần Ngọc Tâm','NV','Nam','06/05/1986',
    'Lầu 6, 222 Điện Biên Phủ, Phường 07, Quận 3, TP Hồ Chí Minh','0673632594','CNA');
insert into CNA.NHANVIEN values('NV24','Phạm Thị Kháng','NV','Nữ','25/12/1986',
    'Phòng số 7 trong khu Trung Tâm ươm Tạo Doanh Nghiệp Công Ngh, Phường 14, Quận 10, TP Hồ Chí Minh','0898614447','CNA');
insert into CNA.NHANVIEN values('NV25','Lê Hồng Minh','NV','Nam','06/01/1986',
    '135/37/50 Nguyễn Hữu Cảnh, Phường 22, Quận Bình Thạnh, TP Hồ Chí Minh','0324827371','CNA');
    
----Insert dữ liệu vào table KHACHHANG
insert into CNA.KHACHHANG values('KH01','Lương Thị Huệ Tài',
    '10-B6-6 Sky Garden 3 P. Tân Phong','Nữ','086235728','0862357289','Việt Nam','CNA');
insert into CNA.KHACHHANG values('KH02','Nguyễn Thị Bích Phượng',
    '159/14 Phạm Văn Hai P05','Nữ','086235729','0822456729','Việt Nam','CNA');
insert into CNA.KHACHHANG values('KH03','Đoàn Thị Chuyền',
    '45/1 Phạm Đăng Giảng, P.BHH','Nữ','086235730','0369776631','Việt Nam','CNA');
insert into CNA.KHACHHANG values('KH04','Hà Văn Sang',
    '467E Tổ 5 P.Phước Long B','Nam','086235731','0576599894','Việt Nam','CNA');
insert into CNA.KHACHHANG values('KH05','Mạc Duy Hạnh',
    'E2/58 ấp 5 X.Đa Phước','Nam','086235732','0679444414','Việt Nam','CNA');
insert into CNA.KHACHHANG values('KH06','Nguyễn Đình Hải',
    'H1 K300 Lê Trung Nghĩa P12','Nam','086235733','0723559123','Việt Nam','CNA');
insert into CNA.KHACHHANG values('KH07','Vũ Văn Nhẫn',
    '117 KP2 P. Hiệp Thành','Nam','086235734','0311753888','Việt Nam','CNA');
insert into CNA.KHACHHANG values('KH08','Nguyễn Trọng An',
    '3123 Phạm Thế Hiển P.07','Nam','086235735','0424146362','Việt Nam','CNA');
insert into CNA.KHACHHANG values('KH09','Đỗ Thị Cửu',
    '08 Đường 19, KP1, P. BTĐ','Nữ','086235736','0419691483','Việt Nam','CNA');
insert into CNA.KHACHHANG values('KH10','Ngô Văn Lưu',
    'D20/25A ấp 4 X.Vĩnh Lộc B','Nam','086235737','0953192423','Việt Nam','CNA');
insert into CNA.KHACHHANG values('KH11','Lê Quang Thành',
    '86 Kp3 P. Bình Thuận','Nam','086235738','0894256595','Việt Nam','CNA');
insert into CNA.KHACHHANG values('KH12','Trần Huỳnh Sơn',
    '501 HL2 P.BTĐ','Nam','086235739','0389876945','Việt Nam','CNA');
insert into CNA.KHACHHANG values('KH13','Trần Minh Sơn',
    '6-6A Đường D52 P12','Nam','086235740','0874281299','Việt Nam','CNA');
insert into CNA.KHACHHANG values('KH14','Trần Thị Kim Trang',
    '61 Đường 359 KP5 P.Phước Long B','Nữ','086235741','0369776796','Việt Nam','CNA');
insert into CNA.KHACHHANG values('KH15','Vũ Kim  Chi',
    '553/16/4 Lũy Bán Bích, P. Phú Thạnh','Nữ','086235742','0145359226','Việt Nam','CNA');
insert into CNA.KHACHHANG values('KH16','Hồ Thị Xuyến',
    '248 Phú Thọ Hòa','Nữ','086235743','0144192533','Việt Nam','CNA');
insert into CNA.KHACHHANG values('KH17','Trì Hà Hải',
    '50 Văn Cao, P. Phú Thọ Hòa','Nam','086235744','0749647865','Việt Nam','CNA');
insert into CNA.KHACHHANG values('KH18','San Quế Nam',
    '342/24 Thoại Ngọc Hầu, P. Phú Thạnh','Nam','086235745','0562118766','Việt Nam','CNA');
insert into CNA.KHACHHANG values('KH19','Nguyễn Ngọc Hoàng',
    '75 Liên khu 2-10 KP10 P.BHH A','Nam','086235746','0322846115','Việt Nam','CNA');
insert into CNA.KHACHHANG values('KH20','Phan Nguyễn Hồng Ân',
    '551 Hoàng Văn Thụ P04','Nam','086235747','0984494928','Việt Nam','CNA');
insert into CNA.KHACHHANG values('KH21','Phạm Văn Cường',
    '248 KP3 QL1A P.BHH B','Nam','086235748','0793769633','Việt Nam','CNA');
insert into CNA.KHACHHANG values('KH22','Trương Thị Phương Khanh',
    'C805 Him Lam 6A X.Bình Hưng','Nữ','086235749','0528924621','Việt Nam','CNA');
insert into CNA.KHACHHANG values('KH23','Lê Thị Bích Hồng',
    'Chợ Bình Điền Khu T Sạp 004','Nữ','086235750','0255622315','Việt Nam','CNA');
insert into CNA.KHACHHANG values('KH24','Nguyễn Thị Mỹ Dung',
    'C2/15 ấp 3 X.Bình Hưng','Nữ','086235751','0193231788','Việt Nam','CNA');
insert into CNA.KHACHHANG values('KH25','Tất Duy Kiên',
    '36A Âu Cơ P09','Nam','086235752','0217742941','Việt Nam','CNA');
    
----Insert dữ liệu vào table PHIEU_DK_P
insert into CNA.PHIEU_DK_P values('PDK01','KH11','NV24','10/06/2006','PA005','CNA');
insert into CNA.PHIEU_DK_P values('PDK02','KH05','NV19','14/08/2006','PA003','CNA');
insert into CNA.PHIEU_DK_P values('PDK03','KH15','NV23','10/02/2007','PA014','CNA');
insert into CNA.PHIEU_DK_P values('PDK04','KH15','NV23','08/08/2007','PA014','CNA');
insert into CNA.PHIEU_DK_P values('PDK05','KH05','NV14','10/08/2007','PA016','CNA');
insert into CNA.PHIEU_DK_P values('PDK06','KH06','NV15','13/08/2008','PA003','CNA');
insert into CNA.PHIEU_DK_P values('PDK07','KH09','NV22','08/06/2009','PA003','CNA');
insert into CNA.PHIEU_DK_P values('PDK08','KH10','NV23','09/06/2009','PA004','CNA');
insert into CNA.PHIEU_DK_P values('PDK09','KH11','NV24','10/06/2009','PA005','CNA');
insert into CNA.PHIEU_DK_P values('PDK10','KH04','NV13','11/08/2009','PA015','CNA');
insert into CNA.PHIEU_DK_P values('PDK11','KH13','NV10','04/09/2009','PA015','CNA');
insert into CNA.PHIEU_DK_P values('PDK12','KH05','NV14','12/09/2009','PA016','CNA');
insert into CNA.PHIEU_DK_P values('PDK13','KH06','NV15','13/09/2009','PA003','CNA');
insert into CNA.PHIEU_DK_P values('PDK14','KH04','NV13','01/08/2010','PA015','CNA');
insert into CNA.PHIEU_DK_P values('PDK15','KH14','NV22','07/08/2010','PA016','CNA');
insert into CNA.PHIEU_DK_P values('PDK16','KH12','NV25','05/09/2010','PA014','CNA');
insert into CNA.PHIEU_DK_P values('PDK18','KH03','NV08','05/09/2011','PA008','CNA');
insert into CNA.PHIEU_DK_P values('PDK19','KH12','NV25','05/09/2011','PA014','CNA');
insert into CNA.PHIEU_DK_P values('PDK20','KH13','NV10','06/09/2011','PA015','CNA');
insert into CNA.PHIEU_DK_P values('PDK21','KH14','NV22','07/09/2011','PA016','CNA');
insert into CNA.PHIEU_DK_P values('PDK22','KH15','NV23','08/09/2011','PA014','CNA');
insert into CNA.PHIEU_DK_P values('PDK23','KH04','NV13','09/09/2011','PA015','CNA');
insert into CNA.PHIEU_DK_P values('PDK24','KH05','NV19','14/09/2011','PA003','CNA');
insert into CNA.PHIEU_DK_P values('PDK30','KH02','NV07','19/09/2012','PA002','CNA');
insert into CNA.PHIEU_DK_P values('PDK41','KH04','NV09','11/10/2015','PA009','CNA');
insert into CNA.PHIEU_DK_P values('PDK56','KH05','NV10','02/09/2018','PA010','CNA');
insert into CNA.PHIEU_DK_P values('PDK60','KH08','NV10','05/04/2019','PA019','CNA');
insert into CNA.PHIEU_DK_P values('PDK61','KH12','NV20','06/04/2019','PA020','CNA');
insert into CNA.PHIEU_DK_P values('PDK62','KH13','NV21','07/04/2019','PA025','CNA');
insert into CNA.PHIEU_DK_P values('PDK67','KH07','NV09','04/06/2020','PA012','CNA');
insert into CNA.PHIEU_DK_P values('PDK69','KH06','NV08','03/11/2020','PA011','CNA');
insert into CNA.PHIEU_DK_P values('PDK71','KH01','NV06','12/09/2021','PA001','CNA');

----Insert dữ liệu vào table DICHVU
insert into CNA.DICHVU values('DV1','COMBO MÁT SA + TẮM HƠI',2000000);
insert into CNA.DICHVU values('DV2','KARAOKE',500000);
insert into CNA.DICHVU values('DV3','GIẶT ỦI',200000);
insert into CNA.DICHVU values('DV4','MÁT SA',800000);
insert into CNA.DICHVU values('DV5','TẮM HƠI',400000);

----Insert dữ liệu vào table DK_DV
insert into CNA.DK_DV values('DK_DV01','DV1','PDK01','12/06/2006','CNA');
insert into CNA.DK_DV values('DK_DV02','DV2','PDK01','12/06/2006','CNA');
insert into CNA.DK_DV values('DK_DV03','DV1','PDK02','16/08/2006','CNA');
insert into CNA.DK_DV values('DK_DV04','DV2','PDK03','08/03/2007','CNA');
insert into CNA.DK_DV values('DK_DV05','DV2','PDK05','12/08/2007','CNA');
insert into CNA.DK_DV values('DK_DV06','DV3','PDK05','13/08/2007','CNA');
insert into CNA.DK_DV values('DK_DV07','DV2','PDK04','08/09/2007','CNA');
insert into CNA.DK_DV values('DK_DV08','DV3','PDK06','13/09/2008','CNA');
insert into CNA.DK_DV values('DK_DV09','DV5','PDK06','13/09/2008','CNA');
insert into CNA.DK_DV values('DK_DV10','DV2','PDK09','13/06/2009','CNA');
insert into CNA.DK_DV values('DK_DV11','DV1','PDK08','19/07/2009','CNA');
insert into CNA.DK_DV values('DK_DV12','DV2','PDK08','19/07/2009','CNA');
insert into CNA.DK_DV values('DK_DV13','DV1','PDK07','28/07/2009','CNA');
insert into CNA.DK_DV values('DK_DV14','DV4','PDK07','29/07/2009','CNA');
insert into CNA.DK_DV values('DK_DV15','DV1','PDK10','01/09/2009','CNA');
insert into CNA.DK_DV values('DK_DV16','DV1','PDK11','06/09/2009','CNA');
insert into CNA.DK_DV values('DK_DV17','DV2','PDK12','15/09/2009','CNA');
insert into CNA.DK_DV values('DK_DV18','DV2','PDK13','03/10/2009','CNA');
insert into CNA.DK_DV values('DK_DV19','DV2','PDK14','09/08/2010','CNA');
insert into CNA.DK_DV values('DK_DV20','DV3','PDK15','09/08/2010','CNA');
insert into CNA.DK_DV values('DK_DV21','DV1','PDK16','07/09/2010','CNA');
insert into CNA.DK_DV values('DK_DV23','DV2','PDK20','07/09/2011','CNA');
insert into CNA.DK_DV values('DK_DV24','DV3','PDK21','07/09/2011','CNA');
insert into CNA.DK_DV values('DK_DV25','DV2','PDK19','09/09/2011','CNA');
insert into CNA.DK_DV values('DK_DV26','DV1','PDK22','28/09/2011','CNA');
insert into CNA.DK_DV values('DK_DV31','DV1','PDK23','17/09/2012','CNA');
insert into CNA.DK_DV values('DK_DV32','DV2','PDK24','24/09/2012','CNA');
insert into CNA.DK_DV values('DK_DV44','DV3','PDK41','11/10/2015','CNA');
insert into CNA.DK_DV values('DK_DV45','DV2','PDK30','17/10/2015','CNA');
insert into CNA.DK_DV values('DK_DV60','DV2','PDK56','02/09/2018','CNA');
insert into CNA.DK_DV values('DK_DV61','DV2','PDK18','11/10/2018','CNA');
insert into CNA.DK_DV values('DK_DV65','DV1','PDK61','06/04/2019','CNA');
insert into CNA.DK_DV values('DK_DV66','DV1','PDK62','07/04/2019','CNA');
insert into CNA.DK_DV values('DK_DV69','DV3','PDK60','02/09/2019','CNA');
insert into CNA.DK_DV values('DK_DV72','DV4','PDK67','04/06/2020','CNA');
insert into CNA.DK_DV values('DK_DV74','DV3','PDK69','03/11/2020','CNA');
insert into CNA.DK_DV values('DK_DV76','DV1','PDK71','12/09/2021','CNA');

----Insert dữ liệu vào table HOADON_QL
insert into CNA.HOADON_QL values('HD01','10/02/2007',1,'NV19','PDK02','CNA');
insert into CNA.HOADON_QL values('HD02','08/05/2007',2,'NV23','PDK03','CNA');
insert into CNA.HOADON_QL values('HD03','12/09/2007',3,'NV14','PDK05','CNA');
insert into CNA.HOADON_QL values('HD04','10/06/2008',4,'NV24','PDK01','CNA');
insert into CNA.HOADON_QL values('HD05','13/01/2009',5,'NV15','PDK06','CNA');
insert into CNA.HOADON_QL values('HD06','28/08/2009',4,'NV22','PDK07','CNA');
insert into CNA.HOADON_QL values('HD07','08/09/2009',5,'NV23','PDK04','CNA');
insert into CNA.HOADON_QL values('HD08','19/12/2009',4,'NV23','PDK08','CNA');
insert into CNA.HOADON_QL values('HD09','01/05/2010',4,'NV13','PDK10','CNA');
insert into CNA.HOADON_QL values('HD10','06/05/2010',3,'NV10','PDK11','CNA');
insert into CNA.HOADON_QL values('HD11','09/09/2010',3,'NV13','PDK14','CNA');
insert into CNA.HOADON_QL values('HD12','05/02/2011',5,'NV25','PDK16','CNA');
insert into CNA.HOADON_QL values('HD13','07/02/2011',4,'NV22','PDK15','CNA');
insert into CNA.HOADON_QL values('HD14','15/04/2011',2,'NV14','PDK12','CNA');
insert into CNA.HOADON_QL values('HD15','06/10/2011',4,'NV10','PDK20','CNA');
insert into CNA.HOADON_QL values('HD16','27/11/2011',4,'NV22','PDK21','CNA');
insert into CNA.HOADON_QL values('HD18','28/04/2012',5,'NV23','PDK22','CNA');
insert into CNA.HOADON_QL values('HD19','17/09/2012',5,'NV13','PDK23','CNA');
insert into CNA.HOADON_QL values('HD20','24/09/2012',4,'NV19','PDK24','CNA');
insert into CNA.HOADON_QL values('HD26','09/05/2014',4,'NV25','PDK19','CNA');
insert into CNA.HOADON_QL values('HD43','03/12/2016',4,'NV15','PDK13','CNA');
insert into CNA.HOADON_QL values('HD47','13/06/2019',3,'NV24','PDK09','CNA');

----Insert dữ liệu vào table HOADON_NV
insert into CNA.HOADON_NV values('HD01','10/02/2007',180,128000000,'NV19','KH05','PDK02','CNA');
insert into CNA.HOADON_NV values('HD02','08/05/2007',87,52700000,'NV23','KH15','PDK03','CNA');
insert into CNA.HOADON_NV values('HD03','12/09/2007',33,20500000,'NV14','KH05','PDK05','CNA');
insert into CNA.HOADON_NV values('HD04','10/06/2008',731,514200000,'NV24','KH11','PDK01','CNA');
insert into CNA.HOADON_NV values('HD05','13/01/2009',153,107700000,'NV15','KH06','PDK06','CNA');
insert into CNA.HOADON_NV values('HD06','28/08/2009',81,59500000,'NV22','KH09','PDK07','CNA');
insert into CNA.HOADON_NV values('HD07','08/09/2009',762,457700000,'NV23','KH15','PDK04','CNA');
insert into CNA.HOADON_NV values('HD08','19/12/2009',193,137600000,'NV23','KH10','PDK08','CNA');
insert into CNA.HOADON_NV values('HD09','01/05/2010',263,159800000,'NV13','KH04','PDK10','CNA');
insert into CNA.HOADON_NV values('HD10','06/05/2010',244,148400000,'NV10','KH13','PDK11','CNA');
insert into CNA.HOADON_NV values('HD11','09/09/2010',39,23900000,'NV13','KH04','PDK14','CNA');
insert into CNA.HOADON_NV values('HD12','05/02/2011',153,93800000,'NV25','KH12','PDK16','CNA');
insert into CNA.HOADON_NV values('HD13','07/02/2011',184,110600000,'NV22','KH14','PDK15','CNA');
insert into CNA.HOADON_NV values('HD14','15/04/2011',580,348500000,'NV14','KH05','PDK12','CNA');
insert into CNA.HOADON_NV values('HD15','06/10/2011',30,18500000,'NV10','KH13','PDK20','CNA');
insert into CNA.HOADON_NV values('HD16','27/11/2011',81,48800000,'NV22','KH14','PDK21','CNA');
insert into CNA.HOADON_NV values('HD18','28/04/2012',233,141800000,'NV23','KH15','PDK22','CNA');
insert into CNA.HOADON_NV values('HD19','17/09/2012',374,226400000,'NV13','KH04','PDK23','CNA');
insert into CNA.HOADON_NV values('HD20','24/09/2012',376,263700000,'NV19','KH05','PDK24','CNA');
insert into CNA.HOADON_NV values('HD26','09/05/2014',977,586700000,'NV25','KH12','PDK19','CNA');
insert into CNA.HOADON_NV values('HD43','03/12/2016',2638,1847100000,'NV15','KH06','PDK13','CNA');
insert into CNA.HOADON_NV values('HD47','13/06/2019',3655,2559000000,'NV24','KH11','PDK09','CNA');

-------------------------------------------------------------------------------
-- 2.4 Xem DL đã nhập vào
SELECT * FROM CNA.LOAIPHONG;
SELECT * FROM CNA.CHINHANH;
SELECT * FROM CNA.PHONG;
SELECT * FROM CNA.CHUCVU;
SELECT * FROM CNA.NHANVIEN;
SELECT * FROM CNA.KHACHHANG;
SELECT * FROM CNA.PHIEU_DK_P;
SELECT * FROM CNA.DICHVU;
SELECT * FROM CNA.DK_DV;
SELECT * FROM CNA.HOADON_QL;
SELECT * FROM CNA.HOADON_NV;

-------------------------------------------------------------------------------
-- 2.5 Kiểm tra Trigger
-- Trigger: Ngày đăng ký dịch vụ không được trước ngày đăng ký phòng 
--          NGAYDK_DV >= NGAYDK_P

/*
- Bối cảnh: PHIEU_DK_P, DK_DV

- Nội dung: Với mọi pdk_p thuộc PHIEU_DK_P, tồn tại dk_dv thuộc DK_DV: 
    pdk_p.MAPDK = dk_dv.MAPDK và NGAYDK_DV >= NGAYDK_P 
                
- Bảng tầm ảnh hưởng:
          Thêm	 Xóa	Sửa
DK_DV	    +	  -	     +(NGAYDK_DV, MAPDK)
PHIEU_DK_P  -	  -	     +(NGAYDK_P)

*/
-- Trigger INSERT, UPDATE trên bảng DK_DV
-- Kiểm tra DL đang có
SELECT PDK_P.MAPDK, NGAYDK_P, NGAYDK_DV
FROM CNA.PHIEU_DK_P PDK_P JOIN CNA.DK_DV DK_DV ON PDK_P.MAPDK = DK_DV.MAPDK;

-- TH UPDATE
-- TH lỗi: VN: NGAYDK_P = , NGAYDK_DV = '' 
--          -> Sửa NGAYDK_DV = 
UPDATE CNA.DK_DV
SET NGAYDK_DV = ''
WHERE MAPDK = '';

-- TH thành công: VN: NGAYDK_P = , NGAYDK_DV = '' 
--          -> Sửa NGAYDK_DV = 
UPDATE CNA.DK_DV
SET NGAYDK_DV = ''
WHERE MAPDK = '';


-- TH INSERT
-- TH lỗi: VN: NGAYDK_P = 
--          -> Thêm DK_DV có NGAYDK_DV = 
-- INSERT INTO CNA.DK_DV VALUES ();


-- TH thành công: VN: NGAYDK_P = 15/01/1956
--          -> Thêm DK_DV có NGAYDK_DV = 
--INSERT INTO CNA.DK_DV VALUES ();

----------------------------------------------------
-- Trigger UPDATE trên bảng PHIEU_DK_P
-- Kiểm tra DL đang có
SELECT PDK_P.MAPDK, NGAYDK_P, NGAYDK_DV
FROM CNA.PHIEU_DK_P PDK_P JOIN CNA.DK_DV DK_DV ON PDK_P.MAPDK = DK_DV.MAPDK;

-- TH lỗi: VN: NGAYDK_P = 15/01/1956, NGAYDK_DV = '13h15 20/12/2015' 
--          -> Sửa NGAYDK_P = 20/12/2016
UPDATE CNA.PHIEU_DK_P
SET NGAYDK_P = ''
WHERE MAPDK = '';

-- TH Thành công: VN: NGAYDK_P = 15/01/1956, NGAYDK_DV = '13h15 20/12/2015' 
--          -> Sửa NGAYDK_P = 20/12/2000
UPDATE CNA.PHIEU_DK_P
SET NGAYDK_P = ''
WHERE MAPDK = '';

---------------------------------------------------
-- Trả DL lại trạng thái ban đầu khi chưa kiểm tra Trigger
DELETE FROM CNA.DK_DV
WHERE MADK_DV = '';

UPDATE CNA.DK_DV
SET NGAYDK_DV = ''
WHERE MAPDK = '';

UPDATE CNA.PHIEU_DK_P
SET NGAYDK_P = ''
WHERE MAPDK = '';

-------------------------------------------------------------------------------
-- III. Trên SQL Plus đăng nhập /as sysdba, sau đó tạo user và phân quyền
----- GiamDoc 
    CREATE USER GiamDoc IDENTIFIED BY GiamDoc;

	GRANT CONNECT TO GiamDoc; 
    
	GRANT SELECT ON CNA.LOAIPHONG TO GiamDoc; 
    GRANT SELECT ON CNA.CHINHANH TO GiamDoc;
    GRANT SELECT ON CNA.PHONG TO GiamDoc;
    GRANT SELECT ON CNA.CHUCVU TO GiamDoc;
    GRANT SELECT ON CNA.NHANVIEN TO GiamDoc;
    GRANT SELECT ON CNA.KHACHHANG TO GiamDoc;
    GRANT SELECT ON CNA.PHIEU_DK_P TO GiamDoc;
    GRANT SELECT ON CNA.DICHVU TO GiamDoc;
    GRANT SELECT ON CNA.DK_DV TO GiamDoc;
    GRANT SELECT ON CNA.HOADON_QL TO GiamDoc;
    GRANT SELECT ON CNA.HOADON_NV TO GiamDoc;
    
	GRANT CREATE DATABASE LINK TO GiamDoc; 

----- QuanLy
    CREATE USER QuanLy IDENTIFIED BY QuanLy;

	GRANT CONNECT TO QuanLy;
    
	GRANT SELECT ON CNA.NHANVIEN TO QuanLy;
    GRANT SELECT ON CNA.HOADON_QL TO QuanLy;

----- NhanVien
	CREATE USER NhanVien IDENTIFIED BY NhanVien;
    
    GRANT CONNECT TO NhanVien;
    
    GRANT SELECT ON CNA.LOAIPHONG TO NhanVien; 
	GRANT SELECT ON CNA.PHONG TO NhanVien; 
    GRANT SELECT ON CNA.KHACHHANG TO NhanVien; 
    GRANT SELECT ON CNA.PHIEU_DK_P TO NhanVien; 
    GRANT SELECT ON CNA.DICHVU TO NhanVien; 
    GRANT SELECT ON CNA.DK_DV TO NhanVien; 
    GRANT SELECT ON CNA.HOADON_NV TO NhanVien;
    
    GRANT CREATE DATABASE LINK TO NhanVien; 

-------------------------------------------------------------------------------
-- IV. Trên SQL Plus tạo Database link đến user GiamDoc Chi nhánh B
CONNECT GiamDoc/GiamDoc;
CREATE DATABASE LINK GD_dblink CONNECT TO GiamDoc IDENTIFIED BY GiamDoc 
    USING 'gd_sn';

CONNECT NhanVien/NhanVien;
CREATE DATABASE LINK NV_dblink CONNECT TO NhanVien IDENTIFIED BY NhanVien 
    USING 'nv_sn';

-------------------------------------------------------------------------------
-- V. Thực hiện Procedure, Function phân tán
-- 5.1 Thực hiện Procedure


--------------------------------------
-- 5.2 Thực hiện Function


-------------------------------------------------------------------------------
-- VI. Thực hiện các câu truy vấn
/* Query 1. Tài khoản nhân viên:  */
CONNECT NhanVien/NhanVien;
