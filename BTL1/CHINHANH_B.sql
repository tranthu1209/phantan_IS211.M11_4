------------------------- Tại MÁY B ---------------------------------
-- 1. Trên SQL Plus đăng nhập /as sysdba, sau đó tạo user để insert DL
----- 1.1 Tạo một user CNB với password là CNB
CREATE USER CNB IDENTIFIED BY CNB;

----- 1.2 Gán quyền connect, dba cho tài khoản CNB
GRANT CONNECT, DBA TO CNB;

-------------------------------------------------------------------------------
-- 2. Mở SQL Dev, tạo connect CHI NHANH B dùng user CNB
----- 2.1 Chạy lệnh tạo bảng
CREATE TABLE CNB.LOAIPHONG
(
	MALP char(3) PRIMARY KEY,
	TENLP varchar2 (40) NOT NULL,
	TRANGBI varchar2(100) NOT NULL,
	GIA number NOT NULL
);

CREATE TABLE CNB.CHINHANH(
	MACN char(3) PRIMARY KEY, 
	TENCN varchar2(30) NOT NULL,
	DIACHI varchar2(80) NOT NULL,
	SDT char(10) NOT NULL UNIQUE
);

CREATE TABLE CNB.PHONG
(
	MAPHONG char(5) PRIMARY KEY, 
	TENPHONG varchar2(30) NOT NULL,
	TINHTRANG varchar2(20) NOT NULL,
	MALP char(3) REFERENCES CNB.LOAIPHONG(MALP),
	MACN char(3) REFERENCES CNB.CHINHANH(MACN)
);

CREATE TABLE CNB.CHUCVU(
	MACV char(2) PRIMARY KEY, 
	TENCV varchar2(30) NOT NULL
);

CREATE TABLE CNB.NHANVIEN(
	MANV char(4) PRIMARY KEY,
	TENNV varchar2(40) NOT NULL,
	MACV char(2) REFERENCES CNB.CHUCVU(MACV),
	GIOITINH varchar2(6) NOT NULL,
	NGAYSINH date NOT NULL,
	DIACHI varchar2(200) NOT NULL, 
	SDT varchar(10) NOT NULL UNIQUE,
	MACN char(3) REFERENCES CNB.CHINHANH(MACN) 
);

CREATE TABLE CNB.KHACHHANG(
	MAKH char(4) PRIMARY KEY,
	TENKH varchar2(40) NOT NULL,
	DIACHI varchar2(200), 
	GIOITINH varchar2(6) NOT NULL,
	CMND char(9) NOT NULL,
	SDT varchar2(10) NOT NULL UNIQUE,
	QUOCTICH varchar2(30),
	MACN char(3) REFERENCES CNB.CHINHANH(MACN)
);

CREATE TABLE CNB.PHIEU_DK_P(
	MAPDK char(5) PRIMARY KEY,
	MAKH char(4) REFERENCES CNB.KHACHHANG(MAKH),
	MANV char(4) REFERENCES CNB.NHANVIEN(MANV),
	NGAYDK_P date NOT NULL,
	MAPHONG	char(5) REFERENCES CNB.PHONG(MAPHONG),
	MACN char(3) REFERENCES CNB.CHINHANH(MACN)
);

CREATE TABLE CNB.DICHVU(
	MADV char(4) PRIMARY KEY,
	TENDV varchar2(50) NOT NULL,
	PHIDV number NOT NULL
);

CREATE TABLE CNB.DK_DV(
	MADK_DV char(7) PRIMARY KEY,
	MADV char(4) REFERENCES CNB.DICHVU(MADV),
	MAPDK char(5) REFERENCES CNB.PHIEU_DK_P(MAPDK),
	NGAYDK_DV date NOT NULL,
	MACN char(3) REFERENCES CNB.CHINHANH(MACN)
);

CREATE TABLE CNB.HOADON_QL(
	MAHD char(4) PRIMARY KEY,
	NGAYTHANHTOAN date NOT NULL,
	DANHGIA number NOT NULL,
	MANV char(4) REFERENCES CNB.NHANVIEN(MANV),
	MAPDK char(5) REFERENCES CNB.PHIEU_DK_P(MAPDK),
	MACN char(3) REFERENCES CNB.CHINHANH(MACN)
);

CREATE TABLE CNB.HOADON_NV(
	MAHD char(4) PRIMARY KEY,
	NGAYTHANHTOAN date NOT NULL,
	SONGAY number NOT NULL, 
	TONGTIEN number NOT NULL,
	MANV char(4) REFERENCES CNB.NHANVIEN(MANV),
	MAKH char(4) REFERENCES CNB.KHACHHANG(MAKH),
	MAPDK char(5) REFERENCES CNB.PHIEU_DK_P(MAPDK),
	MACN char(3) REFERENCES CNB.CHINHANH(MACN)
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
ON CNB.DK_DV FOR EACH ROW
DECLARE
    v_ngaydk_p DATE;
BEGIN
    SELECT NGAYDK_P INTO v_ngaydk_p
    FROM CNB.PHIEU_DK_P PDK_P
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
ON CNB.PHIEU_DK_P FOR EACH ROW
DECLARE
    v_ngaydk_dv DATE;
BEGIN
    SELECT NGAYDK_DV INTO v_ngaydk_dv
    FROM CNB.DK_DV DK_DV
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
ON CNB.HOADON_NV FOR EACH ROW
DECLARE
    v_ngaydk_p DATE;
BEGIN
    SELECT NGAYDK_P INTO v_ngaydk_p
    FROM CNB.PHIEU_DK_P PDK_P
    WHERE PDK_P.MAPDK = :NEW.MAPDK;
    
    IF (:NEW.SONGAY != :NEW.NGAYTHANHTOAN - v_ngaydk_p) THEN
        RAISE_APPLICATION_ERROR(-20102, 'Số ngày đã bị tính sai');
    END IF;    
END;

---------------------------------------
-- Trigger UPDATE trên bảng PHIEU_DK_P
CREATE OR REPLACE TRIGGER UPDATE_DK_P_TT
AFTER UPDATE
ON CNB.PHIEU_DK_P FOR EACH ROW
DECLARE
    v_ngaythanhtoan DATE;
    v_songay number;
BEGIN
    SELECT NGAYTHANHTOAN INTO v_ngaythanhtoan
    FROM CNB.HOADON_NV HD_NV
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
ON CNB.HOADON_NV FOR EACH ROW
DECLARE
    v_sum_phidv NUMBER;
    v_gia_P NUMBER;
BEGIN
    SELECT SUM(PHIDV) INTO v_sum_phidv
    FROM CNB.DK_DV DK_DV, CNB.DICHVU DIV
    WHERE DK_DV.MAPDK = :NEW.MAPDK AND DK_DV.MADV = DIV.MADV
    GROUP BY :NEW.MAPDK;
    
    SELECT GIA*:NEW.SONGAY INTO  v_gia_P
    FROM CNB.LOAIPHONG LP, CNB.PHONG P, CNB.PHIEU_DK_P PDK
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
insert into CNB.LOAIPHONG values ('LP1','PHÒNG VIP1','TIVI, TỦ LẠNH, ĐIỀU HÒA, 
GIƯỜNG VIP1, WIFI, MÁY NƯỚC NÓNG',700000);
insert into CNB.LOAIPHONG values ('LP2','PHÒNG VIP2','TIVI, TỦ LẠNH, ĐIỀU HÒA, 
GIƯỜNG VIP2, WIFI',600000);
insert into CNB.LOAIPHONG values ('LP3','PHÒNG THƯỜNG','TIVI, WIFI, GIƯỜNG',
        400000);

----Insert dữ liệu vào table CHINHANH
insert into CNB.CHINHANH values ('CNB','Chi nhánh Quận 1','Quận 1, TP HCM','0939013112');

----Insert dữ liệu vào table PHONG
insert into CNB.PHONG values ('PB001','PHÒNG B001','TRỐNG','LP1','CNB');
insert into CNB.PHONG values ('PB002','PHÒNG B002','TRỐNG','LP1','CNB');
insert into CNB.PHONG values ('PB003','PHÒNG B003','ĐANG SỬ DỤNG','LP1','CNB');
insert into CNB.PHONG values ('PB004','PHÒNG B004','ĐANG SỬ DỤNG','LP1','CNB');
insert into CNB.PHONG values ('PB005','PHÒNG B005','ĐANG SỬ DỤNG','LP1','CNB');
insert into CNB.PHONG values ('PB006','PHÒNG B006','TRỐNG','LP2','CNB');
insert into CNB.PHONG values ('PB007','PHÒNG B007','TRỐNG','LP2','CNB');
insert into CNB.PHONG values ('PB008','PHÒNG B008','ĐANG SỬ DỤNG','LP2','CNB');
insert into CNB.PHONG values ('PB009','PHÒNG B009','ĐANG SỬ DỤNG','LP2','CNB');
insert into CNB.PHONG values ('PB010','PHÒNG B010','ĐANG SỬ DỤNG','LP2','CNB');
insert into CNB.PHONG values ('PB011','PHÒNG B011','TRỐNG','LP2','CNB');
insert into CNB.PHONG values ('PB012','PHÒNG B012','TRỐNG','LP2','CNB');
insert into CNB.PHONG values ('PB013','PHÒNG B013','TRỐNG','LP2','CNB');
insert into CNB.PHONG values ('PB014','PHÒNG B014','TRỐNG','LP2','CNB');
insert into CNB.PHONG values ('PB015','PHÒNG B015','TRỐNG','LP2','CNB');
insert into CNB.PHONG values ('PB016','PHÒNG B016','TRỐNG','LP2','CNB');
insert into CNB.PHONG values ('PB017','PHÒNG B017','TRỐNG','LP2','CNB');
insert into CNB.PHONG values ('PB018','PHÒNG B018','ĐANG SỬ DỤNG','LP2','CNB');
insert into CNB.PHONG values ('PB019','PHÒNG B019','ĐANG SỬ DỤNG','LP2','CNB');
insert into CNB.PHONG values ('PB020','PHÒNG B020','ĐANG SỬ DỤNG','LP2','CNB');
insert into CNB.PHONG values ('PB021','PHÒNG B021','ĐANG SỬ DỤNG','LP2','CNB');
insert into CNB.PHONG values ('PB022','PHÒNG B022','TRỐNG','LP2','CNB');
insert into CNB.PHONG values ('PB023','PHÒNG B023','TRỐNG','LP2','CNB');
insert into CNB.PHONG values ('PB024','PHÒNG B024','ĐANG SỬ DỤNG','LP2','CNB');
insert into CNB.PHONG values ('PB025','PHÒNG B025','ĐANG SỬ DỤNG','LP3','CNB');
insert into CNB.PHONG values ('PB026','PHÒNG B026','ĐANG SỬ DỤNG','LP3','CNB');
insert into CNB.PHONG values ('PB027','PHÒNG B027','ĐANG SỬ DỤNG','LP3','CNB');
insert into CNB.PHONG values ('PB028','PHÒNG B028','ĐANG SỬ DỤNG','LP3','CNB');
insert into CNB.PHONG values ('PB029','PHÒNG B029','ĐANG SỬ DỤNG','LP3','CNB');
insert into CNB.PHONG values ('PB030','PHÒNG B030','TRỐNG','LP3','CNB');

----Insert dữ liệu vào table CHUCVU
insert into CNB.CHUCVU values ('GD','GIÁM ĐỐC');
insert into CNB.CHUCVU values ('QL','QUẢN LÝ');
insert into CNB.CHUCVU values ('NV','NHÂN VIÊN');

----Insert dữ liệu vào table NHANVIEN
insert into CNB.NHANVIEN values('NV26','Tôn Nữ Thúy Kiều','GD','Nữ','23/10/1985',
    'Tòa Nhà Bitexco Financial Tower, Số 2 Đường Hải Triều, Phường Bến Nghé, Quận 1, TP Hồ Chí Minh','0621482256','CNB');
insert into CNB.NHANVIEN values('NV27','Đào Thị Phượng','QL','Nữ','30/10/1983',
    '258/13 Trần Hưng Đạo, Phường Nguyễn Cư Trinh, Quận 1, TP Hồ Chí Minh','0465757751','CNB');
insert into CNB.NHANVIEN values('NV28','Hồ Thị Lý','NV','Nam','15/05/1987',
    '469 Điện Biên Phủ, Phường 03, Quận 3, TP Hồ Chí Minh','0854726321','CNB');
insert into CNB.NHANVIEN values('NV29','Phạm Văn Thành','NV','Nam','01/10/1986',
    'Tòa Nhà Rosana, Số 60 Nguyễn Đình Chiểu, Phường Đa Kao, Quận 1, TP Hồ Chí Minh','0835491544','CNB');
insert into CNB.NHANVIEN values('NV30','Đặng Thị Khuyên','NV','Nữ','06/11/1986',
    'Lầu 1, 2A/12 Nguyễn Thị Minh Khai, Phường Đa Kao, Quận 1, TP Hồ Chí Minh','0311279726','CNB');
insert into CNB.NHANVIEN values('NV31','Bùi Hữu Bình','NV','Nam','06/10/1987',
    '59 Nguyễn Quý Yêm, Phường An Lạc, Quận Bình Tân, TP Hồ Chí Minh','0513862863','CNB');
insert into CNB.NHANVIEN values('NV32','Trần Thị Bích Phượng','NV','Nữ','06/05/1986',
    'Phòng 8.6, Tòa Nhà Le Meridien, 3C Tôn Đức Thắng, Phường Bến Nghé, Quận 1, TP Hồ Chí Minh','0978792874','CNB');
insert into CNB.NHANVIEN values('NV33','Lê  Văn Lập','NV','Nam','25/12/1986',
    'Lầu 1, 170 Bùi Thị Xuân, Phường Phạm Ngũ Lão, Quận 1, TP Hồ Chí Minh','0559311124','CNB');
insert into CNB.NHANVIEN values('NV34','Nguyễn Hồng Sinh','NV','Nam','06/01/1986',
    '33/2 Lý Văn Phức, Phường Tân Định, Quận 1, TP Hồ Chí Minh','0949843499','CNB');
insert into CNB.NHANVIEN values('NV35','Bùi Đắc Khoa','NV','Nam','23/10/1985',
    '649/58/7 Đường Điện Biên Phủ, Phường 25, Quận Bình Thạnh, TP Hồ Chí Minh','0621672815','CNB');
insert into CNB.NHANVIEN values('NV36','Tô Thanh Tâm','NV','Nữ','30/10/1983',
    '90 Nguyễn Đình Chiểu, Phường Đa Kao, Quận 1, TP Hồ Chí Minh','0925529461','CNB');
insert into CNB.NHANVIEN values('NV37','Võ Anh Vũ','NV','Nam','15/05/1987',
    'Số 3 đường 13, khu phố 4, Phường Bình An, Quận 2, TP Hồ Chí Minh','0693387442','CNB');
insert into CNB.NHANVIEN values('NV38','Nguyễn Hồng Liêm','NV','Nam','01/10/1986',
    '37 Đường số 9, Cư Xá Bình Thới, Phường 8, Quận 11, TP Hồ Chí Minh','0375862819','CNB');
insert into CNB.NHANVIEN values('NV39','Huỳnh Thị Sanh','NV','Nữ','06/11/1986',
    '140/17/35 Lê Đức Thọ, Phường 6, Quận Gò Vấp, TP Hồ Chí Minh','0211176535','CNB');
insert into CNB.NHANVIEN values('NV40','Lê Thị Thảo Trang','NV','Nữ','06/10/1987',
    '115/11/2C Phạm Hữu Lầu, Phường Phú Mỹ, Quận 7, TP Hồ Chí Minh','0538393692','CNB');
insert into CNB.NHANVIEN values('NV41','Đoàn Thị Liên','NV','Nữ','06/05/1986',
    '135 Hai Bà Trưng, Phường Bến Nghé, Quận 1, TP Hồ Chí Minh','0235746912','CNB');
insert into CNB.NHANVIEN values('NV42','Phạm Tân Nhật Bảo','NV','Nam','25/12/1986',
    'Phòng 1209, Saigon Trade Center, 37 Tôn Đức Thắng, Phường Bến Nghé, Quận 1, TP Hồ Chí Minh','0715521478','CNB');
insert into CNB.NHANVIEN values('NV43','Nguyễn Thị Thảo Ly','NV','Nữ','06/01/1986',
    'Số 134/3 Đường số 1, Phường 16, Quận Gò Vấp, TP Hồ Chí Minh','0364292378','CNB');
insert into CNB.NHANVIEN values('NV44','Quản Lê Thanh Lý','NV','Nữ','23/10/1985',
    '174/81/18 Nguyễn Thiện Thuật, Phường 03, Quận 3, TP Hồ Chí Minh','0277587845','CNB');
insert into CNB.NHANVIEN values('NV45','Trần Văn Ba','NV','Nam','30/10/1983',
    'Văn phòng 05, Tầng 24 Tòa nhà Pearl Plaza, 561A Điện Biên Ph, Phường 25, Quận Bình Thạnh, TP Hồ Chí Minh','0545796388','CNB');
insert into CNB.NHANVIEN values('NV46','Phan Ngọc Bảo Kha','NV','Nam','15/05/1987',
    'Số nhà 86/33A đường Đình Phong Phú, Phường Tăng Nhơn Phú B, Quận 9, TP Hồ Chí Minh','0752494451','CNB');
insert into CNB.NHANVIEN values('NV47','Nguyễn Văn Hân','NV','Nữ','01/10/1986',
    'Tầng 03, Tòa nhà The Vista, 628C Xa Lộ Hà Nội, Phường An Phú, Quận 2, TP Hồ Chí Minh','0634322181','CNB');
insert into CNB.NHANVIEN values('NV48','Vũ Mạnh Hùng','NV','Nam','06/11/1986',
    'Căn hộ số 106, Tòa nhà Golden Aparment Số 120/10-12-14 Nguyễ, Phường Thảo Điền, Quận 2, TP Hồ Chí Minh','0233598255','CNB');
insert into CNB.NHANVIEN values('NV49','Võ Thị Tâm','NV','Nữ','06/10/1987',
    'Lầu 1, Tòa nhà H3, 384 Hoàng Diệu, phường 06, Quận 4, TP Hồ Chí Minh','0226162623','CNB');
insert into CNB.NHANVIEN values('NV50','Trần Thế Hiền','NV','Nam','06/05/1986',
    '11/4A Đường liên khu 5-6, Phường Bình Hưng Hòa B, Quận Bình Tân, TP Hồ Chí Minh','0843671989','CNB');

----Insert dữ liệu vào table KHACHHANG
insert into CNB.KHACHHANG values('KH26','Châu Thanh Tuấn',
    '6/2 TCH21 Kp4 Tổ 38 P.Tân Chánh Hiệp','Nam','086235753','0154885616','Việt Nam','CNB');
insert into CNB.KHACHHANG values('KH27','Nguyễn Văn Minh',
    '85 KP7, Tây Lân, P.Bình Trị Đông A','Nam','086235754','0348466345','Việt Nam','CNB');
insert into CNB.KHACHHANG values('KH28','Nguyễn Văn Hóa',
    'A4/28 ấp 1 X.Vĩnh Lộc B','Nam','086235755','0236115495','Việt Nam','CNB');
insert into CNB.KHACHHANG values('KH29','Trịnh Thị Thu Thuỷ',
    '1007/11 Lạc Long Quân P11','Nữ','086235756','0517296571','Việt Nam','CNB');
insert into CNB.KHACHHANG values('KH30','Đỗ Thị Lang',
    '57 Hiền Vương, P. Phú Thạnh','Nữ','086235757','0232299418','Việt Nam','CNB');
insert into CNB.KHACHHANG values('KH31','Đỗ Trọng Tuệ',
    '57 Hiền Vương, P. Phú Thạnh','Nam','086235758','0426695638','Việt Nam','CNB');
insert into CNB.KHACHHANG values('KH32','Nguyễn Thị Thu Nga',
    '538 Lê Văn Sỹ , Phường 14 , Quận 3','Nữ','086235759','0748427956','Việt Nam','CNB');
insert into CNB.KHACHHANG values('KH33','Đỗ Huỳnh Ngọc Bích',
    '311/17 Kênh Tân Hóa','Nữ','086235760','0268687695','Việt Nam','CNB');
insert into CNB.KHACHHANG values('KH34','Nguyễn Ngô Hoàng',
    'B18/23 ấp 3B X.Bình Hưng','Nam','086235761','0935988285','Việt Nam','CNB');
insert into CNB.KHACHHANG values('KH35','Hoàng Minh Thuý',
    '45 Hồng Hà P02','Nữ','086235762','0122392731','Việt Nam','CNB');
insert into CNB.KHACHHANG values('KH36','Lê Thị Thiện Hiền',
    '228 Võ văn tần , P.05 , Q.03','Nữ','086235763','0916718725','Việt Nam','CNB');
insert into CNB.KHACHHANG values('KH37','Trương Quang Thành',
    'Nhà số 7, đường 19, KP2, P. Bình An','Nam','086235764','0891944238','Việt Nam','CNB');
insert into CNB.KHACHHANG values('KH38','Võ Ngọc Trang',
    '158 Bùi Thị Xuân P03','Nữ','086235765','0348398339','Việt Nam','CNB');
insert into CNB.KHACHHANG values('KH39','Nguyễn Chí Hiếu',
    '93 Trần Quang Diệu , Phường 13 , Quận 3','Nam','086235766','0116414898','Việt Nam','CNB');
insert into CNB.KHACHHANG values('KH40','Hồ Văn Sáu',
    '17 Đường 62, KP6, P. Thảo Điền','Nam','086235767','0516422698','Việt Nam','CNB');
insert into CNB.KHACHHANG values('KH41','Nguyễn Thị Thân',
    'B19-20-21 Đường TMT Kp4 P.Trung Mỹ Tây','Nữ','086235768','0624675344','Việt Nam','CNB');
insert into CNB.KHACHHANG values('KH42','Ngô Nguyên Đức',
    '388 Đường 26/3 P.BHH','Nam','086235769','0782566964','Việt Nam','CNB');
insert into CNB.KHACHHANG values('KH43','Trần Thanh Tâm',
    '44 Đồng Đen P14','Nam','086235770','0264188343','Việt Nam','CNB');
insert into CNB.KHACHHANG values('KH44','Bùi Minh Công',
    '125/198A Lương Thế Vinh, P.Tân Thới Hòa','Nam','086235771','0284143977','Việt Nam','CNB');
insert into CNB.KHACHHANG values('KH45','Diệp Lệ Dung',
    '207/47/4A Hồ Học Lãm, P.AL','Nữ','086235772','0942692498','Việt Nam','CNB');
insert into CNB.KHACHHANG values('KH46','Lê Văn Lam',
    '68 Lê Văn Bền P. Tân Kiểng','Nam','086235773','0665227286','Việt Nam','CNB');
insert into CNB.KHACHHANG values('KH47','Lâm Thị Hồng Nga',
    '327/9 Âu Cơ, P. Phú Trung','Nữ','086235774','0162946752','Việt Nam','CNB');
insert into CNB.KHACHHANG values('KH48','Nguyễn Văn Tuấn',
    '95/42 Lê Văn Lương Kp1 P. Tân Kiểng','Nam','086235775','0517919875','Việt Nam','CNB');
insert into CNB.KHACHHANG values('KH49','Lý Chánh Thành',
    '373 Thạch Lam, P.Phú Thạnh','Nam','086235776','0972442961','Việt Nam','CNB');
insert into CNB.KHACHHANG values('KH50','Nguyễn Thu Hà',
    '449/67 Trường Chinh P.14','Nữ','086235777','0168249278','Việt Nam','CNB');
    
----Insert dữ liệu vào table PHIEU_DK_P
insert into CNB.PHIEU_DK_P values('PDK17','KH49','NV45','25/01/2011','PB030','CNB');
insert into CNB.PHIEU_DK_P values('PDK25','KH33','NV46','14/10/2011','PB030','CNB');
insert into CNB.PHIEU_DK_P values('PDK26','KH43','NV42','22/10/2011','PB014','CNB');
insert into CNB.PHIEU_DK_P values('PDK27','KH31','NV44','24/11/2011','PB023','CNB');
insert into CNB.PHIEU_DK_P values('PDK28','KH47','NV33','19/03/2012','PB014','CNB');
insert into CNB.PHIEU_DK_P values('PDK29','KH30','NV32','18/09/2012','PB013','CNB');
insert into CNB.PHIEU_DK_P values('PDK31','KH48','NV34','20/10/2012','PB015','CNB');
insert into CNB.PHIEU_DK_P values('PDK32','KH49','NV29','15/03/2013','PB013','CNB');
insert into CNB.PHIEU_DK_P values('PDK33','KH43','NV30','16/03/2013','PB014','CNB');
insert into CNB.PHIEU_DK_P values('PDK34','KH49','NV41','21/08/2013','PB013','CNB');
insert into CNB.PHIEU_DK_P values('PDK35','KH27','NV31','03/10/2013','PB015','CNB');
insert into CNB.PHIEU_DK_P values('PDK36','KH27','NV43','11/10/2013','PB015','CNB');
insert into CNB.PHIEU_DK_P values('PDK37','KH26','NV32','17/10/2013','PB012','CNB');
insert into CNB.PHIEU_DK_P values('PDK38','KH49','NV45','25/03/2014','PB030','CNB');
insert into CNB.PHIEU_DK_P values('PDK39','KH49','NV41','21/10/2014','PB013','CNB');
insert into CNB.PHIEU_DK_P values('PDK40','KH43','NV42','22/10/2014','PB014','CNB');
insert into CNB.PHIEU_DK_P values('PDK42','KH26','NV32','14/10/2015','PB012','CNB');
insert into CNB.PHIEU_DK_P values('PDK43','KH49','NV29','15/10/2015','PB013','CNB');
insert into CNB.PHIEU_DK_P values('PDK44','KH43','NV30','16/10/2015','PB014','CNB');
insert into CNB.PHIEU_DK_P values('PDK45','KH27','NV31','17/10/2015','PB015','CNB');
insert into CNB.PHIEU_DK_P values('PDK46','KH30','NV32','18/10/2015','PB013','CNB');
insert into CNB.PHIEU_DK_P values('PDK47','KH47','NV33','19/10/2015','PB014','CNB');
insert into CNB.PHIEU_DK_P values('PDK48','KH48','NV34','20/10/2015','PB015','CNB');
insert into CNB.PHIEU_DK_P values('PDK49','KH27','NV43','23/10/2015','PB015','CNB');
insert into CNB.PHIEU_DK_P values('PDK50','KH31','NV44','24/10/2015','PB023','CNB');
insert into CNB.PHIEU_DK_P values('PDK51','KH33','NV46','26/10/2015','PB030','CNB');
insert into CNB.PHIEU_DK_P values('PDK52','KH46','NV31','02/06/2017','PB019','CNB');
insert into CNB.PHIEU_DK_P values('PDK53','KH47','NV32','03/06/2017','PB020','CNB');
insert into CNB.PHIEU_DK_P values('PDK54','KH48','NV33','04/07/2017','PB021','CNB');
insert into CNB.PHIEU_DK_P values('PDK55','KH41','NV29','17/01/2018','PB005','CNB'); --
insert into CNB.PHIEU_DK_P values('PDK57','KH47','NV31','11/10/2018','PB027','CNB'); --
insert into CNB.PHIEU_DK_P values('PDK58','KH48','NV26','12/12/2018','PB028','CNB');
insert into CNB.PHIEU_DK_P values('PDK59','KH29','NV31','13/12/2018','PB029','CNB'); --
insert into CNB.PHIEU_DK_P values('PDK63','KH42','NV35','18/04/2019','PB008','CNB'); --
insert into CNB.PHIEU_DK_P values('PDK64','KH50','NV33','06/06/2019','PB025','CNB'); --
insert into CNB.PHIEU_DK_P values('PDK65','KH28','NV34','07/08/2019','PB026','CNB'); --
insert into CNB.PHIEU_DK_P values('PDK66','KH49','NV34','05/09/2019','PB024','CNB');
insert into CNB.PHIEU_DK_P values('PDK68','KH45','NV30','11/10/2020','PB018','CNB');
insert into CNB.PHIEU_DK_P values('PDK70','KH44','NV29','05/09/2021','PB010','CNB');
insert into CNB.PHIEU_DK_P values('PDK72','KH39','NV27','15/09/2021','PB003','CNB'); --
insert into CNB.PHIEU_DK_P values('PDK73','KH40','NV33','16/09/2021','PB004','CNB'); --
insert into CNB.PHIEU_DK_P values('PDK74','KH43','NV36','19/09/2021','PB009','CNB'); --

----Insert dữ liệu vào table DICHVU
insert into CNB.DICHVU values('DV1','COMBO MÁT SA + TẮM HƠI',2000000);
insert into CNB.DICHVU values('DV2','KARAOKE',500000);
insert into CNB.DICHVU values('DV3','GIẶT ỦI',200000);
insert into CNB.DICHVU values('DV4','MÁT SA',800000);
insert into CNB.DICHVU values('DV5','TẮM HƠI',400000);
insert into CNB.DICHVU values('DV6','BUFFE',300000);

----Insert dữ liệu vào table DK_DV
insert into CNB.DK_DV values('DK_DV22','DV1','PDK17','15/03/2011','CNB');
insert into CNB.DK_DV values('DK_DV27','DV2','PDK25','16/10/2011','CNB');
insert into CNB.DK_DV values('DK_DV28','DV2','PDK26','12/11/2011','CNB');
insert into CNB.DK_DV values('DK_DV29','DV3','PDK27','21/12/2011','CNB');
insert into CNB.DK_DV values('DK_DV30','DV1','PDK28','19/05/2012','CNB');
insert into CNB.DK_DV values('DK_DV33','DV1','PDK29','18/10/2012','CNB');
insert into CNB.DK_DV values('DK_DV34','DV2','PDK31','20/12/2012','CNB');
insert into CNB.DK_DV values('DK_DV35','DV2','PDK32','15/03/2013','CNB');
insert into CNB.DK_DV values('DK_DV36','DV3','PDK33','16/06/2013','CNB');
insert into CNB.DK_DV values('DK_DV37','DV1','PDK34','21/08/2013','CNB');
insert into CNB.DK_DV values('DK_DV38','DV1','PDK37','18/10/2013','CNB');
insert into CNB.DK_DV values('DK_DV39','DV1','PDK35','17/10/2014','CNB');
insert into CNB.DK_DV values('DK_DV40','DV2','PDK38','20/10/2014','CNB');
insert into CNB.DK_DV values('DK_DV41','DV1','PDK36','23/10/2014','CNB');
insert into CNB.DK_DV values('DK_DV42','DV2','PDK40','11/11/2014','CNB');
insert into CNB.DK_DV values('DK_DV43','DV2','PDK39','18/02/2015','CNB');
insert into CNB.DK_DV values('DK_DV46','DV1','PDK45','27/10/2015','CNB');
insert into CNB.DK_DV values('DK_DV47','DV1','PDK51','29/10/2015','CNB');
insert into CNB.DK_DV values('DK_DV48','DV2','PDK47','03/11/2015','CNB');
insert into CNB.DK_DV values('DK_DV49','DV1','PDK46','13/11/2015','CNB');
insert into CNB.DK_DV values('DK_DV50','DV2','PDK48','14/11/2015','CNB');
insert into CNB.DK_DV values('DK_DV51','DV2','PDK49','25/11/2015','CNB');
insert into CNB.DK_DV values('DK_DV52','DV1','PDK42','14/12/2015','CNB');
insert into CNB.DK_DV values('DK_DV53','DV1','PDK43','15/04/2016','CNB');
insert into CNB.DK_DV values('DK_DV54','DV2','PDK44','19/05/2016','CNB');
insert into CNB.DK_DV values('DK_DV55','DV1','PDK50','24/12/2016','CNB');
insert into CNB.DK_DV values('DK_DV56','DV2','PDK52','03/06/2017','CNB');
insert into CNB.DK_DV values('DK_DV57','DV2','PDK53','04/06/2017','CNB');
insert into CNB.DK_DV values('DK_DV58','DV2','PDK54','04/08/2017','CNB');
insert into CNB.DK_DV values('DK_DV59','DV3','PDK55','18/01/2018','CNB');
insert into CNB.DK_DV values('DK_DV62','DV2','PDK57','11/10/2018','CNB');
insert into CNB.DK_DV values('DK_DV63','DV2','PDK58','12/12/2018','CNB');
insert into CNB.DK_DV values('DK_DV64','DV3','PDK59','14/12/2018','CNB');
insert into CNB.DK_DV values('DK_DV67','DV2','PDK63','19/04/2019','CNB');
insert into CNB.DK_DV values('DK_DV68','DV2','PDK64','06/07/2019','CNB');
insert into CNB.DK_DV values('DK_DV70','DV2','PDK65','07/09/2019','CNB');
insert into CNB.DK_DV values('DK_DV71','DV3','PDK66','07/09/2019','CNB');
insert into CNB.DK_DV values('DK_DV73','DV5','PDK68','13/10/2020','CNB');
insert into CNB.DK_DV values('DK_DV75','DV3','PDK70','05/09/2021','CNB');
insert into CNB.DK_DV values('DK_DV77','DV5','PDK72','15/09/2021','CNB');
insert into CNB.DK_DV values('DK_DV78','DV5','PDK74','19/09/2021','CNB');
insert into CNB.DK_DV values('DK_DV79','DV5','PDK72','16/11/2021','CNB');
insert into CNB.DK_DV values('DK_DV80','DV4','PDK73','19/12/2021','CNB');
insert into CNB.DK_DV values('DK_DV81','DV3','PDK73','20/12/2021','CNB');

----Insert dữ liệu vào table HOADON_QL
insert into CNB.HOADON_QL values('HD17','15/03/2012',5,'NV45','PDK17','CNB');
insert into CNB.HOADON_QL values('HD21','16/10/2012',3,'NV46','PDK25','CNB');
insert into CNB.HOADON_QL values('HD22','21/12/2012',4,'NV44','PDK27','CNB');
insert into CNB.HOADON_QL values('HD23','18/10/2013',3,'NV32','PDK29','CNB');
insert into CNB.HOADON_QL values('HD24','12/01/2014',3,'NV42','PDK26','CNB');
insert into CNB.HOADON_QL values('HD25','21/03/2014',3,'NV41','PDK34','CNB');
insert into CNB.HOADON_QL values('HD27','17/10/2014',3,'NV31','PDK35','CNB');
insert into CNB.HOADON_QL values('HD28','21/10/2014',5,'NV45','PDK38','CNB');
insert into CNB.HOADON_QL values('HD29','23/10/2014',5,'NV43','PDK36','CNB');
insert into CNB.HOADON_QL values('HD30','11/01/2015',5,'NV42','PDK40','CNB');
insert into CNB.HOADON_QL values('HD31','18/02/2015',5,'NV41','PDK39','CNB');
insert into CNB.HOADON_QL values('HD32','20/02/2015',4,'NV34','PDK31','CNB');
insert into CNB.HOADON_QL values('HD33','19/05/2015',5,'NV33','PDK28','CNB');
insert into CNB.HOADON_QL values('HD34','16/06/2015',4,'NV30','PDK33','CNB');
insert into CNB.HOADON_QL values('HD35','14/07/2015',5,'NV32','PDK37','CNB');
insert into CNB.HOADON_QL values('HD36','15/08/2015',4,'NV29','PDK32','CNB');
insert into CNB.HOADON_QL values('HD37','25/11/2015',5,'NV43','PDK49','CNB');
insert into CNB.HOADON_QL values('HD38','29/11/2015',5,'NV46','PDK51','CNB');
insert into CNB.HOADON_QL values('HD39','13/12/2015',5,'NV32','PDK46','CNB');
insert into CNB.HOADON_QL values('HD40','03/08/2016',5,'NV33','PDK47','CNB');
insert into CNB.HOADON_QL values('HD41','14/09/2016',5,'NV34','PDK48','CNB');
insert into CNB.HOADON_QL values('HD42','27/10/2016',5,'NV31','PDK45','CNB');
insert into CNB.HOADON_QL values('HD44','14/12/2016',4,'NV32','PDK42','CNB');
insert into CNB.HOADON_QL values('HD45','24/12/2016',4,'NV44','PDK50','CNB');
insert into CNB.HOADON_QL values('HD46','15/04/2019',4,'NV29','PDK43','CNB');
insert into CNB.HOADON_QL values('HD48','19/05/2021',3,'NV30','PDK44','CNB');

----Insert dữ liệu vào table HOADON_NV
insert into CNB.HOADON_NV values('HD17','15/03/2012',415,168000000,'NV45','KH49','PDK17','CNB');
insert into CNB.HOADON_NV values('HD21','16/10/2012',368,147700000,'NV46','KH33','PDK25','CNB');
insert into CNB.HOADON_NV values('HD22','21/12/2012',393,236000000,'NV44','KH31','PDK27','CNB');
insert into CNB.HOADON_NV values('HD23','18/10/2013',395,239000000,'NV32','KH30','PDK29','CNB');
insert into CNB.HOADON_NV values('HD24','12/01/2014',813,488300000,'NV42','KH43','PDK26','CNB');
insert into CNB.HOADON_NV values('HD25','21/03/2014',212,129200000,'NV41','KH49','PDK34','CNB');
insert into CNB.HOADON_NV values('HD27','17/10/2014',379,229400000,'NV31','KH27','PDK35','CNB');
insert into CNB.HOADON_NV values('HD28','21/10/2014',210,84500000,'NV45','KH49','PDK38','CNB');
insert into CNB.HOADON_NV values('HD29','23/10/2014',377,228200000,'NV43','KH27','PDK36','CNB');
insert into CNB.HOADON_NV values('HD30','11/01/2015',81,49100000,'NV42','KH43','PDK40','CNB');
insert into CNB.HOADON_NV values('HD31','18/02/2015',120,72500000,'NV41','KH49','PDK39','CNB');
insert into CNB.HOADON_NV values('HD32','20/02/2015',853,512300000,'NV34','KH48','PDK31','CNB');
insert into CNB.HOADON_NV values('HD33','19/05/2015',1156,695600000,'NV33','KH47','PDK28','CNB');
insert into CNB.HOADON_NV values('HD34','16/06/2015',822,493400000,'NV30','KH43','PDK33','CNB');
insert into CNB.HOADON_NV values('HD35','14/07/2015',635,383000000,'NV32','KH26','PDK37','CNB');
insert into CNB.HOADON_NV values('HD36','15/08/2015',883,530300000,'NV29','KH49','PDK32','CNB');
insert into CNB.HOADON_NV values('HD37','25/11/2015',33,20300000,'NV43','KH27','PDK49','CNB');
insert into CNB.HOADON_NV values('HD38','29/11/2015',34,15600000,'NV46','KH33','PDK51','CNB');
insert into CNB.HOADON_NV values('HD39','13/12/2015',56,35600000,'NV32','KH30','PDK46','CNB');
insert into CNB.HOADON_NV values('HD40','03/08/2016',289,173900000,'NV33','KH47','PDK47','CNB');
insert into CNB.HOADON_NV values('HD41','14/09/2016',330,198500000,'NV34','KH48','PDK48','CNB');
insert into CNB.HOADON_NV values('HD42','27/10/2016',376,227600000,'NV31','KH27','PDK45','CNB');
insert into CNB.HOADON_NV values('HD44','14/12/2016',427,258200000,'NV32','KH26','PDK42','CNB');
insert into CNB.HOADON_NV values('HD45','24/12/2016',427,258200000,'NV44','KH31','PDK50','CNB');
insert into CNB.HOADON_NV values('HD46','15/04/2019',1278,768800000,'NV29','KH49','PDK43','CNB');
insert into CNB.HOADON_NV values('HD48','19/05/2021',2042,1225700000,'NV30','KH43','PDK44','CNB');

-------------------------------------------------------------------------------
-- 2.4 Xem DL đã nhập vào
SELECT * FROM CNB.LOAIPHONG;
SELECT * FROM CNB.CHINHANH;
SELECT * FROM CNB.PHONG;
SELECT * FROM CNB.CHUCVU;
SELECT * FROM CNB.NHANVIEN;
SELECT * FROM CNB.KHACHHANG;
SELECT * FROM CNB.PHIEU_DK_P;
SELECT * FROM CNB.DICHVU;
SELECT * FROM CNB.DK_DV;
SELECT * FROM CNB.HOADON_QL;
SELECT * FROM CNB.HOADON_NV;

-------------------------------------------------------------------------------
-- III. Trên SQL Plus đăng nhập /as sysdba, sau đó tạo user và phân quyền
----- GiamDoc 
    CREATE USER GiamDoc IDENTIFIED BY GiamDoc;

    GRANT CONNECT TO GiamDoc; 
    GRANT INSERT, UPDATE ON CNB.DICHVU TO GiamDoc;
    
    GRANT SELECT ON CNB.LOAIPHONG TO GiamDoc; 
    GRANT SELECT ON CNB.CHINHANH TO GiamDoc;
    GRANT SELECT ON CNB.PHONG TO GiamDoc;
    GRANT SELECT ON CNB.CHUCVU TO GiamDoc;
    GRANT SELECT ON CNB.NHANVIEN TO GiamDoc;
    GRANT SELECT ON CNB.KHACHHANG TO GiamDoc;
    GRANT SELECT ON CNB.PHIEU_DK_P TO GiamDoc;
    GRANT SELECT ON CNB.DICHVU TO GiamDoc;
    GRANT SELECT ON CNB.DK_DV TO GiamDoc;
    GRANT SELECT ON CNB.HOADON_QL TO GiamDoc;
    GRANT SELECT ON CNB.HOADON_NV TO GiamDoc;
    
    GRANT CREATE DATABASE LINK TO GiamDoc; 

----- QuanLy
    CREATE USER QuanLy IDENTIFIED BY QuanLy;

    GRANT CONNECT TO QuanLy;
    
    GRANT SELECT ON CNB.NHANVIEN TO QuanLy;
    GRANT SELECT ON CNB.HOADON_QL TO QuanLy;

----- NhanVien
    CREATE USER NhanVien IDENTIFIED BY NhanVien;
    
    GRANT CONNECT TO NhanVien;
    
    GRANT SELECT ON CNB.PHONG TO NhanVien; 
    GRANT SELECT ON CNB.KHACHHANG TO NhanVien; 
    GRANT SELECT ON CNB.PHIEU_DK_P TO NhanVien; 
    GRANT SELECT ON CNB.DICHVU TO NhanVien; 
    GRANT SELECT ON CNB.DK_DV TO NhanVien; 
    GRANT SELECT ON CNB.HOADON_NV TO NhanVien;
    
    GRANT CREATE DATABASE LINK TO NhanVien; 

-------------------------------------------------------------------------------
-- IV. Trên SQL Plus tạo Database link đến user GiamDoc Chi nhánh A
CONNECT GiamDoc/GiamDoc;
CREATE DATABASE LINK GD_dblink CONNECT TO GiamDoc IDENTIFIED BY GiamDoc 
    USING 'gd_sn';

CONNECT NhanVien/NhanVien;
CREATE DATABASE LINK NV_dblink CONNECT TO NhanVien IDENTIFIED BY NhanVien 
    USING 'nv_sn';

