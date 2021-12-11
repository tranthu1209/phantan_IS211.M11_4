
-- 1. Trên SQL Plus đăng nhập /as sysdba, sau đó tạo user để insert DL
----- 1.1 Tạo một user BTL1 với password là BTL1
CREATE USER BTL1 IDENTIFIED BY BTL1;

----- 1.2 Gán quyền connect, dba cho tài khoản BTL1
GRANT CONNECT, DBA TO BTL1;

-------------------------------------------------------------------------------
-- 2. Mở SQL Dev, tạo connect BTL1 dùng user BTL1
----- 2.1 Chạy lệnh tạo bảng
CREATE TABLE BTL1.LOAIPHONG
(
	MALP char(3) PRIMARY KEY,
	TENLP varchar2 (40) NOT NULL,
	TRANGBI varchar2(100) NOT NULL,
	GIA number NOT NULL
);

CREATE TABLE BTL1.CHINHANH(
	MACN char(3) PRIMARY KEY, 
	TENCN varchar2(30) NOT NULL,
	DIACHI varchar2(80) NOT NULL,
	SDT char(10) NOT NULL UNIQUE
);

CREATE TABLE BTL1.PHONG
(
	MAPHONG char(5) PRIMARY KEY, 
	TENPHONG varchar2(30) NOT NULL,
	TINHTRANG varchar2(20) NOT NULL,
	MALP char(3) REFERENCES BTL1.LOAIPHONG(MALP),
	MACN char(3) REFERENCES BTL1.CHINHANH(MACN)
);

CREATE TABLE BTL1.CHUCVU(
	MACV char(2) PRIMARY KEY, 
	TENCV varchar2(30) NOT NULL
);

CREATE TABLE BTL1.NHANVIEN(
	MANV char(4) PRIMARY KEY,
	TENNV varchar2(40) NOT NULL,
	MACV char(2) REFERENCES BTL1.CHUCVU(MACV),
	GIOITINH varchar2(6) NOT NULL,
	NGAYSINH date NOT NULL,
	DIACHI varchar2(200) NOT NULL, 
	SDT varchar(10) NOT NULL UNIQUE,
	MACN char(3) REFERENCES BTL1.CHINHANH(MACN) 
);

CREATE TABLE BTL1.KHACHHANG(
	MAKH char(4) PRIMARY KEY,
	TENKH varchar2(40) NOT NULL,
	DIACHI varchar2(200), 
	GIOITINH varchar2(6) NOT NULL,
	CMND char(9) NOT NULL,
	SDT varchar2(10) NOT NULL UNIQUE,
	QUOCTICH varchar2(30),
	MACN char(3) REFERENCES BTL1.CHINHANH(MACN)
);

CREATE TABLE BTL1.PHIEU_DK_P(
	MAPDK char(5) PRIMARY KEY,
	MAKH char(4) REFERENCES BTL1.KHACHHANG(MAKH),
	MANV char(4) REFERENCES BTL1.NHANVIEN(MANV),
	NGAYDK_P date NOT NULL,
	MAPHONG	char(5) REFERENCES BTL1.PHONG(MAPHONG),
	MACN char(3) REFERENCES BTL1.CHINHANH(MACN)
);

CREATE TABLE BTL1.DICHVU(
	MADV char(4) PRIMARY KEY,
	TENDV varchar2(50) NOT NULL,
	PHIDV number NOT NULL
);

CREATE TABLE BTL1.DK_DV(
	MADK_DV char(7) PRIMARY KEY,
	MADV char(4) REFERENCES BTL1.DICHVU(MADV),
	MAPDK char(5) REFERENCES BTL1.PHIEU_DK_P(MAPDK),
	NGAYDK_DV date NOT NULL,
	MACN char(3) REFERENCES BTL1.CHINHANH(MACN)
);

CREATE TABLE BTL1.HOADON(
	MAHD char(4) PRIMARY KEY,
	NGAYTHANHTOAN date NOT NULL,
    SONGAY number NOT NULL, 
	TONGTIEN number NOT NULL,
	DANHGIA number NOT NULL,
	MANV char(4) REFERENCES BTL1.NHANVIEN(MANV),
	MAKH char(4) REFERENCES BTL1.KHACHHANG(MAKH),
	MAPDK char(5) REFERENCES BTL1.PHIEU_DK_P(MAPDK),
	MACN char(3) REFERENCES BTL1.CHINHANH(MACN)
);

-------------------------------------------------------------------------------
----- 2.3 Chạy lệnh Insert DL
ALTER SESSION SET NLS_DATE_FORMAT = ' DD/MM/YYYY HH24:MI:SS ';

----Insert dữ liệu vào table LOAIPHONG
insert into BTL1.LOAIPHONG values ('LP1','PHÒNG VIP1','TIVI, TỦ LẠNH, ĐIỀU HÒA, 
GIƯỜNG VIP1, WIFI, MÁY NƯỚC NÓNG',700000);
insert into BTL1.LOAIPHONG values ('LP2','PHÒNG VIP2','TIVI, TỦ LẠNH, ĐIỀU HÒA, 
GIƯỜNG VIP2, WIFI',600000);
insert into BTL1.LOAIPHONG values ('LP3','PHÒNG THƯỜNG','TIVI, WIFI, GIƯỜNG',
        400000);

----Insert dữ liệu vào table CHINHANH
insert into BTL1.CHINHANH values ('CNA','Chi nhánh Thủ Đức','TP Thủ Đức, TP HCM','0939013321');

insert into BTL1.CHINHANH values ('CNB','Chi nhánh Quận 1','Quận 1, TP HCM','0939013112');

----Insert dữ liệu vào table PHONG
insert into BTL1.PHONG values ('PA001','PHÒNG A001','ĐANG SỬ DỤNG','LP1','CNA');
insert into BTL1.PHONG values ('PA002','PHÒNG A002','ĐANG SỬ DỤNG','LP1','CNA');
insert into BTL1.PHONG values ('PA003','PHÒNG A003','TRỐNG','LP1','CNA');
insert into BTL1.PHONG values ('PA004','PHÒNG A004','TRỐNG','LP1','CNA');
insert into BTL1.PHONG values ('PA005','PHÒNG A005','TRỐNG','LP1','CNA');
insert into BTL1.PHONG values ('PA006','PHÒNG A006','TRỐNG','LP1','CNA');
insert into BTL1.PHONG values ('PA007','PHÒNG A007','TRỐNG','LP1','CNA');
insert into BTL1.PHONG values ('PA008','PHÒNG A008','ĐANG SỬ DỤNG','LP1','CNA');
insert into BTL1.PHONG values ('PA009','PHÒNG A009','ĐANG SỬ DỤNG','LP1','CNA');
insert into BTL1.PHONG values ('PA010','PHÒNG A010','ĐANG SỬ DỤNG','LP1','CNA');
insert into BTL1.PHONG values ('PA011','PHÒNG A011','ĐANG SỬ DỤNG','LP2','CNA');
insert into BTL1.PHONG values ('PA012','PHÒNG A012','ĐANG SỬ DỤNG','LP2','CNA');
insert into BTL1.PHONG values ('PA013','PHÒNG A013','TRỐNG','LP2','CNA');
insert into BTL1.PHONG values ('PA014','PHÒNG A014','TRỐNG','LP2','CNA');
insert into BTL1.PHONG values ('PA015','PHÒNG A015','TRỐNG','LP2','CNA');
insert into BTL1.PHONG values ('PA016','PHÒNG A016','TRỐNG','LP2','CNA');
insert into BTL1.PHONG values ('PA017','PHÒNG A017','TRỐNG','LP2','CNA');
insert into BTL1.PHONG values ('PA018','PHÒNG A018','TRỐNG','LP2','CNA');
insert into BTL1.PHONG values ('PA019','PHÒNG A019','ĐANG SỬ DỤNG','LP2','CNA');
insert into BTL1.PHONG values ('PA020','PHÒNG A020','ĐANG SỬ DỤNG','LP2','CNA');
insert into BTL1.PHONG values ('PA021','PHÒNG A021','TRỐNG','LP3','CNA');
insert into BTL1.PHONG values ('PA022','PHÒNG A022','TRỐNG','LP3','CNA');
insert into BTL1.PHONG values ('PA023','PHÒNG A023','TRỐNG','LP3','CNA');
insert into BTL1.PHONG values ('PA024','PHÒNG A024','TRỐNG','LP3','CNA');
insert into BTL1.PHONG values ('PA025','PHÒNG A025','ĐANG SỬ DỤNG','LP3','CNA');
insert into BTL1.PHONG values ('PA026','PHÒNG A026','TRỐNG','LP3','CNA');
insert into BTL1.PHONG values ('PA027','PHÒNG A027','TRỐNG','LP3','CNA');
insert into BTL1.PHONG values ('PA028','PHÒNG A028','TRỐNG','LP3','CNA');
insert into BTL1.PHONG values ('PA029','PHÒNG A029','TRỐNG','LP3','CNA');
insert into BTL1.PHONG values ('PA030','PHÒNG A030','TRỐNG','LP3','CNA');

insert into BTL1.PHONG values ('PB001','PHÒNG B001','TRỐNG','LP1','CNB');
insert into BTL1.PHONG values ('PB002','PHÒNG B002','TRỐNG','LP1','CNB');
insert into BTL1.PHONG values ('PB003','PHÒNG B003','ĐANG SỬ DỤNG','LP1','CNB');
insert into BTL1.PHONG values ('PB004','PHÒNG B004','ĐANG SỬ DỤNG','LP1','CNB');
insert into BTL1.PHONG values ('PB005','PHÒNG B005','ĐANG SỬ DỤNG','LP1','CNB');
insert into BTL1.PHONG values ('PB006','PHÒNG B006','TRỐNG','LP2','CNB');
insert into BTL1.PHONG values ('PB007','PHÒNG B007','TRỐNG','LP2','CNB');
insert into BTL1.PHONG values ('PB008','PHÒNG B008','ĐANG SỬ DỤNG','LP2','CNB');
insert into BTL1.PHONG values ('PB009','PHÒNG B009','ĐANG SỬ DỤNG','LP2','CNB');
insert into BTL1.PHONG values ('PB010','PHÒNG B010','ĐANG SỬ DỤNG','LP2','CNB');
insert into BTL1.PHONG values ('PB011','PHÒNG B011','TRỐNG','LP2','CNB');
insert into BTL1.PHONG values ('PB012','PHÒNG B012','TRỐNG','LP2','CNB');
insert into BTL1.PHONG values ('PB013','PHÒNG B013','TRỐNG','LP2','CNB');
insert into BTL1.PHONG values ('PB014','PHÒNG B014','TRỐNG','LP2','CNB');
insert into BTL1.PHONG values ('PB015','PHÒNG B015','TRỐNG','LP2','CNB');
insert into BTL1.PHONG values ('PB016','PHÒNG B016','TRỐNG','LP2','CNB');
insert into BTL1.PHONG values ('PB017','PHÒNG B017','TRỐNG','LP2','CNB');
insert into BTL1.PHONG values ('PB018','PHÒNG B018','ĐANG SỬ DỤNG','LP2','CNB');
insert into BTL1.PHONG values ('PB019','PHÒNG B019','ĐANG SỬ DỤNG','LP2','CNB');
insert into BTL1.PHONG values ('PB020','PHÒNG B020','ĐANG SỬ DỤNG','LP2','CNB');
insert into BTL1.PHONG values ('PB021','PHÒNG B021','ĐANG SỬ DỤNG','LP2','CNB');
insert into BTL1.PHONG values ('PB022','PHÒNG B022','TRỐNG','LP2','CNB');
insert into BTL1.PHONG values ('PB023','PHÒNG B023','TRỐNG','LP2','CNB');
insert into BTL1.PHONG values ('PB024','PHÒNG B024','ĐANG SỬ DỤNG','LP2','CNB');
insert into BTL1.PHONG values ('PB025','PHÒNG B025','ĐANG SỬ DỤNG','LP3','CNB');
insert into BTL1.PHONG values ('PB026','PHÒNG B026','ĐANG SỬ DỤNG','LP3','CNB');
insert into BTL1.PHONG values ('PB027','PHÒNG B027','ĐANG SỬ DỤNG','LP3','CNB');
insert into BTL1.PHONG values ('PB028','PHÒNG B028','ĐANG SỬ DỤNG','LP3','CNB');
insert into BTL1.PHONG values ('PB029','PHÒNG B029','ĐANG SỬ DỤNG','LP3','CNB');
insert into BTL1.PHONG values ('PB030','PHÒNG B030','TRỐNG','LP3','CNB');

----Insert dữ liệu vào table CHUCVU
insert into BTL1.CHUCVU values ('GD','GIÁM ĐỐC');
insert into BTL1.CHUCVU values ('QL','QUẢN LÝ');
insert into BTL1.CHUCVU values ('NV','NHÂN VIÊN');

----Insert dữ liệu vào table NHANVIEN
insert into BTL1.NHANVIEN values('NV01','Nguyễn Anh Tuấn','GD','Nam','01/10/1986',
    '29/7A Trần Hữu Trang, Phường 11, Quận Phú Nhuận, TP Hồ Chí Minh','0715884274','CNA');
insert into BTL1.NHANVIEN values('NV02','Hồ Văn Trí','QL','Nam','06/11/1986',
    'Lầu 5 Tòa nhà Tập đoàn FIT, Số 276 Nguyễn Đình Chiểu, Phường 06, Quận 3, TP Hồ Chí Minh','0696338439','CNA');
insert into BTL1.NHANVIEN values('NV03','Nguyễn Thị Đào','NV','Nam','06/10/1987',
    '96/14 Khu Phố 4, Đường Tân Mỹ, Phường Tân Thuận Tây, Quận 7, TP Hồ Chí Minh','0594969363','CNA');
insert into BTL1.NHANVIEN values('NV04','Lê Thanh Triệu','NV','Nam','06/05/1986',
    '40/40/4A Tô Hiệu, Phường Tân Thới Hoà, Quận Tân phú, TP Hồ Chí Minh','0835897558','CNA');
insert into BTL1.NHANVIEN values('NV05','Lý Văn Đức','NV','Nam','25/12/1986',
    'Số 2 Đường 49, Phường Bình Trưng Đông, Quận 2, TP Hồ Chí Minh','0665193285','CNA');
insert into BTL1.NHANVIEN values('NV06','Hồ Ngọc Chúc','NV','Nữ','06/01/1986',
    'Phòng số 2, Tòa nhà 6A, lô 6A, đường số 3, Công viên phần mề, phường Tân Chánh Hiệp, Quận 12, TP Hồ Chí Minh','0292632426','CNA');
insert into BTL1.NHANVIEN values('NV07','Nguyễn Thị Nhạn','NV','Nam','23/10/1985',
    '15/4/20 Lê Lai, Phường 12, Quận Tân Bình, TP Hồ Chí Minh','0576843374','CNA');
insert into BTL1.NHANVIEN values('NV08','Vũ Viết Tâm','NV','Nữ','30/10/1983',
    '95/26 Lê Văn Sỹ, Phường 13, Quận Phú Nhuận, TP Hồ Chí Minh','0635797651','CNA');
insert into BTL1.NHANVIEN values('NV09','Lê Ngọc Sương','NV','Nữ','15/05/1987',
    '235/65 Nam Kỳ Khởi Nghĩa, Phường 07, Quận 3, TP Hồ Chí Minh','0634332766','CNA');
insert into BTL1.NHANVIEN values('NV10','Lê Văn Thọ','NV','Nam','25/06/1989',
    '44A/27 Bùi Văn Ba, Phường Tân Thuận Đông, Quận 7, TP Hồ Chí Minh','0936382211','CNA');
insert into BTL1.NHANVIEN values('NV11','Quách Thị Thanh','NV','Nữ','01/10/1986',
    'L7 Và L8, Tầng Lửng Lô B, Tòa Nhà Chung Cư Khánh Hội 01, Số, phường 01, Quận 4, TP Hồ Chí Minh','0173995882','CNA');
insert into BTL1.NHANVIEN values('NV12','Hứa Ngọc Mỹ','NV','Nữ','06/11/1986',
    '25/1C Nguyễn Hậu, Phường Tân Thành, Quận Tân phú, TP Hồ Chí Minh','0362771822','CNA');
insert into BTL1.NHANVIEN values('NV13','Nguyễn Tiến Dũng','NV','Nam','06/10/1987',
    '178/4B Pasteur, Phường Bến Nghé, Quận 1, TP Hồ Chí Minh','0227918759','CNA');
insert into BTL1.NHANVIEN values('NV14','Nguyễn Văn Trình','NV','Nam','06/05/1986',
    '29 Đường Nội Khu Mỹ Toàn 2, Khu Đô Thị Phú Mỹ Hưng, Phường Tân Phong, Quận 7, TP Hồ Chí Minh','0556379741','CNA');
insert into BTL1.NHANVIEN values('NV15','Đào Thị Mỹ Hồng','NV','Nữ','25/12/1986',
    '47/42/22A Bùi Đình Tuý, Phường 24, Quận Bình Thạnh, TP Hồ Chí Minh','0345323162','CNA');
insert into BTL1.NHANVIEN values('NV16','Nguyễn Thị Ái Thuỷ','NV','Nữ','06/01/1986',
    '94 Lương Trúc Đàm, Phường Hiệp Tân, Quận Tân phú, TP Hồ Chí Minh','0837652688','CNA');
insert into BTL1.NHANVIEN values('NV17','Trương Thị Thu Hương','NV','Nữ','23/10/1985',
    '484A Lê Văn Việt, Phường Tăng Nhơn Phú A, Quận 9, TP Hồ Chí Minh','0613493729','CNA');
insert into BTL1.NHANVIEN values('NV18','Nguyễn Thị Bích Hằng','NV','Nữ','30/10/1983',
    'Lầu 8, Tòa nhà Mobivi, 104 Mai Thị Lựu, Phường Đa Kao, Quận 1, TP Hồ Chí Minh','0738375233','CNA');
insert into BTL1.NHANVIEN values('NV19','Đoàn Thị Xuân Thảo','NV','Nữ','15/05/1987',
    '21/16 Xuân Thủy, Phường Thảo Điền, Quận 2, TP Hồ Chí Minh','0668679892','CNA');
insert into BTL1.NHANVIEN values('NV20','Huỳnh Thị Nguyên','NV','Nữ','01/10/1986',
    '451/24/4 Tô Hiến Thành, Phường 14, Quận 10, TP Hồ Chí Minh','0584369979','CNA');
insert into BTL1.NHANVIEN values('NV21','Nguyễn Văn Ngọc','NV','Nam','06/11/1986',
    'Tầng 21, Tòa nhà E.Town Central, Số 11 Đoàn Văn Bơ, phường 12, Quận 4, TP Hồ Chí Minh','0828657213','CNA');
insert into BTL1.NHANVIEN values('NV22','Phan Văn Trang','NV','Nữ','06/10/1987',
    'Lầu 1, Tòa nhà H3, Số 384 Hoàng Diệu, phường 06, Quận 4, TP Hồ Chí Minh','0473614631','CNA');
insert into BTL1.NHANVIEN values('NV23','Trần Ngọc Tâm','NV','Nam','06/05/1986',
    'Lầu 6, 222 Điện Biên Phủ, Phường 07, Quận 3, TP Hồ Chí Minh','0673632594','CNA');
insert into BTL1.NHANVIEN values('NV24','Phạm Thị Kháng','NV','Nữ','25/12/1986',
    'Phòng số 7 trong khu Trung Tâm ươm Tạo Doanh Nghiệp Công Ngh, Phường 14, Quận 10, TP Hồ Chí Minh','0898614447','CNA');
insert into BTL1.NHANVIEN values('NV25','Lê Hồng Minh','NV','Nam','06/01/1986',
    '135/37/50 Nguyễn Hữu Cảnh, Phường 22, Quận Bình Thạnh, TP Hồ Chí Minh','0324827371','CNA');

insert into BTL1.NHANVIEN values('NV26','Tôn Nữ Thúy Kiều','GD','Nữ','23/10/1985',
    'Tòa Nhà Bitexco Financial Tower, Số 2 Đường Hải Triều, Phường Bến Nghé, Quận 1, TP Hồ Chí Minh','0621482256','CNB');
insert into BTL1.NHANVIEN values('NV27','Đào Thị Phượng','QL','Nữ','30/10/1983',
    '258/13 Trần Hưng Đạo, Phường Nguyễn Cư Trinh, Quận 1, TP Hồ Chí Minh','0465757751','CNB');
insert into BTL1.NHANVIEN values('NV28','Hồ Thị Lý','NV','Nam','15/05/1987',
    '469 Điện Biên Phủ, Phường 03, Quận 3, TP Hồ Chí Minh','0854726321','CNB');
insert into BTL1.NHANVIEN values('NV29','Phạm Văn Thành','NV','Nam','01/10/1986',
    'Tòa Nhà Rosana, Số 60 Nguyễn Đình Chiểu, Phường Đa Kao, Quận 1, TP Hồ Chí Minh','0835491544','CNB');
insert into BTL1.NHANVIEN values('NV30','Đặng Thị Khuyên','NV','Nữ','06/11/1986',
    'Lầu 1, 2A/12 Nguyễn Thị Minh Khai, Phường Đa Kao, Quận 1, TP Hồ Chí Minh','0311279726','CNB');
insert into BTL1.NHANVIEN values('NV31','Bùi Hữu Bình','NV','Nam','06/10/1987',
    '59 Nguyễn Quý Yêm, Phường An Lạc, Quận Bình Tân, TP Hồ Chí Minh','0513862863','CNB');
insert into BTL1.NHANVIEN values('NV32','Trần Thị Bích Phượng','NV','Nữ','06/05/1986',
    'Phòng 8.6, Tòa Nhà Le Meridien, 3C Tôn Đức Thắng, Phường Bến Nghé, Quận 1, TP Hồ Chí Minh','0978792874','CNB');
insert into BTL1.NHANVIEN values('NV33','Lê  Văn Lập','NV','Nam','25/12/1986',
    'Lầu 1, 170 Bùi Thị Xuân, Phường Phạm Ngũ Lão, Quận 1, TP Hồ Chí Minh','0559311124','CNB');
insert into BTL1.NHANVIEN values('NV34','Nguyễn Hồng Sinh','NV','Nam','06/01/1986',
    '33/2 Lý Văn Phức, Phường Tân Định, Quận 1, TP Hồ Chí Minh','0949843499','CNB');
insert into BTL1.NHANVIEN values('NV35','Bùi Đắc Khoa','NV','Nam','23/10/1985',
    '649/58/7 Đường Điện Biên Phủ, Phường 25, Quận Bình Thạnh, TP Hồ Chí Minh','0621672815','CNB');
insert into BTL1.NHANVIEN values('NV36','Tô Thanh Tâm','NV','Nữ','30/10/1983',
    '90 Nguyễn Đình Chiểu, Phường Đa Kao, Quận 1, TP Hồ Chí Minh','0925529461','CNB');
insert into BTL1.NHANVIEN values('NV37','Võ Anh Vũ','NV','Nam','15/05/1987',
    'Số 3 đường 13, khu phố 4, Phường Bình An, Quận 2, TP Hồ Chí Minh','0693387442','CNB');
insert into BTL1.NHANVIEN values('NV38','Nguyễn Hồng Liêm','NV','Nam','01/10/1986',
    '37 Đường số 9, Cư Xá Bình Thới, Phường 8, Quận 11, TP Hồ Chí Minh','0375862819','CNB');
insert into BTL1.NHANVIEN values('NV39','Huỳnh Thị Sanh','NV','Nữ','06/11/1986',
    '140/17/35 Lê Đức Thọ, Phường 6, Quận Gò Vấp, TP Hồ Chí Minh','0211176535','CNB');
insert into BTL1.NHANVIEN values('NV40','Lê Thị Thảo Trang','NV','Nữ','06/10/1987',
    '115/11/2C Phạm Hữu Lầu, Phường Phú Mỹ, Quận 7, TP Hồ Chí Minh','0538393692','CNB');
insert into BTL1.NHANVIEN values('NV41','Đoàn Thị Liên','NV','Nữ','06/05/1986',
    '135 Hai Bà Trưng, Phường Bến Nghé, Quận 1, TP Hồ Chí Minh','0235746912','CNB');
insert into BTL1.NHANVIEN values('NV42','Phạm Tân Nhật Bảo','NV','Nam','25/12/1986',
    'Phòng 1209, Saigon Trade Center, 37 Tôn Đức Thắng, Phường Bến Nghé, Quận 1, TP Hồ Chí Minh','0715521478','CNB');
insert into BTL1.NHANVIEN values('NV43','Nguyễn Thị Thảo Ly','NV','Nữ','06/01/1986',
    'Số 134/3 Đường số 1, Phường 16, Quận Gò Vấp, TP Hồ Chí Minh','0364292378','CNB');
insert into BTL1.NHANVIEN values('NV44','Quản Lê Thanh Lý','NV','Nữ','23/10/1985',
    '174/81/18 Nguyễn Thiện Thuật, Phường 03, Quận 3, TP Hồ Chí Minh','0277587845','CNB');
insert into BTL1.NHANVIEN values('NV45','Trần Văn Ba','NV','Nam','30/10/1983',
    'Văn phòng 05, Tầng 24 Tòa nhà Pearl Plaza, 561A Điện Biên Ph, Phường 25, Quận Bình Thạnh, TP Hồ Chí Minh','0545796388','CNB');
insert into BTL1.NHANVIEN values('NV46','Phan Ngọc Bảo Kha','NV','Nam','15/05/1987',
    'Số nhà 86/33A đường Đình Phong Phú, Phường Tăng Nhơn Phú B, Quận 9, TP Hồ Chí Minh','0752494451','CNB');
insert into BTL1.NHANVIEN values('NV47','Nguyễn Văn Hân','NV','Nữ','01/10/1986',
    'Tầng 03, Tòa nhà The Vista, 628C Xa Lộ Hà Nội, Phường An Phú, Quận 2, TP Hồ Chí Minh','0634322181','CNB');
insert into BTL1.NHANVIEN values('NV48','Vũ Mạnh Hùng','NV','Nam','06/11/1986',
    'Căn hộ số 106, Tòa nhà Golden Aparment Số 120/10-12-14 Nguyễ, Phường Thảo Điền, Quận 2, TP Hồ Chí Minh','0233598255','CNB');
insert into BTL1.NHANVIEN values('NV49','Võ Thị Tâm','NV','Nữ','06/10/1987',
    'Lầu 1, Tòa nhà H3, 384 Hoàng Diệu, phường 06, Quận 4, TP Hồ Chí Minh','0226162623','CNB');
insert into BTL1.NHANVIEN values('NV50','Trần Thế Hiền','NV','Nam','06/05/1986',
    '11/4A Đường liên khu 5-6, Phường Bình Hưng Hòa B, Quận Bình Tân, TP Hồ Chí Minh','0843671989','CNB');
    
----Insert dữ liệu vào table KHACHHANG
insert into BTL1.KHACHHANG values('KH01','Lương Thị Huệ Tài',
    '10-B6-6 Sky Garden 3 P. Tân Phong','Nữ','086235728','0862357289','Việt Nam','CNA');
insert into BTL1.KHACHHANG values('KH02','Nguyễn Thị Bích Phượng',
    '159/14 Phạm Văn Hai P05','Nữ','086235729','0822456729','Việt Nam','CNA');
insert into BTL1.KHACHHANG values('KH03','Đoàn Thị Chuyền',
    '45/1 Phạm Đăng Giảng, P.BHH','Nữ','086235730','0369776631','Việt Nam','CNA');
insert into BTL1.KHACHHANG values('KH04','Hà Văn Sang',
    '467E Tổ 5 P.Phước Long B','Nam','086235731','0576599894','Việt Nam','CNA');
insert into BTL1.KHACHHANG values('KH05','Mạc Duy Hạnh',
    'E2/58 ấp 5 X.Đa Phước','Nam','086235732','0679444414','Việt Nam','CNA');
insert into BTL1.KHACHHANG values('KH06','Nguyễn Đình Hải',
    'H1 K300 Lê Trung Nghĩa P12','Nam','086235733','0723559123','Việt Nam','CNA');
insert into BTL1.KHACHHANG values('KH07','Vũ Văn Nhẫn',
    '117 KP2 P. Hiệp Thành','Nam','086235734','0311753888','Việt Nam','CNA');
insert into BTL1.KHACHHANG values('KH08','Nguyễn Trọng An',
    '3123 Phạm Thế Hiển P.07','Nam','086235735','0424146362','Việt Nam','CNA');
insert into BTL1.KHACHHANG values('KH09','Đỗ Thị Cửu',
    '08 Đường 19, KP1, P. BTĐ','Nữ','086235736','0419691483','Việt Nam','CNA');
insert into BTL1.KHACHHANG values('KH10','Ngô Văn Lưu',
    'D20/25A ấp 4 X.Vĩnh Lộc B','Nam','086235737','0953192423','Việt Nam','CNA');
insert into BTL1.KHACHHANG values('KH11','Lê Quang Thành',
    '86 Kp3 P. Bình Thuận','Nam','086235738','0894256595','Việt Nam','CNA');
insert into BTL1.KHACHHANG values('KH12','Trần Huỳnh Sơn',
    '501 HL2 P.BTĐ','Nam','086235739','0389876945','Việt Nam','CNA');
insert into BTL1.KHACHHANG values('KH13','Trần Minh Sơn',
    '6-6A Đường D52 P12','Nam','086235740','0874281299','Việt Nam','CNA');
insert into BTL1.KHACHHANG values('KH14','Trần Thị Kim Trang',
    '61 Đường 359 KP5 P.Phước Long B','Nữ','086235741','0369776796','Việt Nam','CNA');
insert into BTL1.KHACHHANG values('KH15','Vũ Kim  Chi',
    '553/16/4 Lũy Bán Bích, P. Phú Thạnh','Nữ','086235742','0145359226','Việt Nam','CNA');
insert into BTL1.KHACHHANG values('KH16','Hồ Thị Xuyến',
    '248 Phú Thọ Hòa','Nữ','086235743','0144192533','Việt Nam','CNA');
insert into BTL1.KHACHHANG values('KH17','Trì Hà Hải',
    '50 Văn Cao, P. Phú Thọ Hòa','Nam','086235744','0749647865','Việt Nam','CNA');
insert into BTL1.KHACHHANG values('KH18','San Quế Nam',
    '342/24 Thoại Ngọc Hầu, P. Phú Thạnh','Nam','086235745','0562118766','Việt Nam','CNA');
insert into BTL1.KHACHHANG values('KH19','Nguyễn Ngọc Hoàng',
    '75 Liên khu 2-10 KP10 P.BHH A','Nam','086235746','0322846115','Việt Nam','CNA');
insert into BTL1.KHACHHANG values('KH20','Phan Nguyễn Hồng Ân',
    '551 Hoàng Văn Thụ P04','Nam','086235747','0984494928','Việt Nam','CNA');
insert into BTL1.KHACHHANG values('KH21','Phạm Văn Cường',
    '248 KP3 QL1A P.BHH B','Nam','086235748','0793769633','Việt Nam','CNA');
insert into BTL1.KHACHHANG values('KH22','Trương Thị Phương Khanh',
    'C805 Him Lam 6A X.Bình Hưng','Nữ','086235749','0528924621','Việt Nam','CNA');
insert into BTL1.KHACHHANG values('KH23','Lê Thị Bích Hồng',
    'Chợ Bình Điền Khu T Sạp 004','Nữ','086235750','0255622315','Việt Nam','CNA');
insert into BTL1.KHACHHANG values('KH24','Nguyễn Thị Mỹ Dung',
    'C2/15 ấp 3 X.Bình Hưng','Nữ','086235751','0193231788','Việt Nam','CNA');
insert into BTL1.KHACHHANG values('KH25','Tất Duy Kiên',
    '36A Âu Cơ P09','Nam','086235752','0217742941','Việt Nam','CNA');

insert into BTL1.KHACHHANG values('KH26','Châu Thanh Tuấn',
    '6/2 TCH21 Kp4 Tổ 38 P.Tân Chánh Hiệp','Nam','086235753','0154885616','Việt Nam','CNB');
insert into BTL1.KHACHHANG values('KH27','Nguyễn Văn Minh',
    '85 KP7, Tây Lân, P.Bình Trị Đông A','Nam','086235754','0348466345','Việt Nam','CNB');
insert into BTL1.KHACHHANG values('KH28','Nguyễn Văn Hóa',
    'A4/28 ấp 1 X.Vĩnh Lộc B','Nam','086235755','0236115495','Việt Nam','CNB');
insert into BTL1.KHACHHANG values('KH29','Trịnh Thị Thu Thuỷ',
    '1007/11 Lạc Long Quân P11','Nữ','086235756','0517296571','Việt Nam','CNB');
insert into BTL1.KHACHHANG values('KH30','Đỗ Thị Lang',
    '57 Hiền Vương, P. Phú Thạnh','Nữ','086235757','0232299418','Việt Nam','CNB');
insert into BTL1.KHACHHANG values('KH31','Đỗ Trọng Tuệ',
    '57 Hiền Vương, P. Phú Thạnh','Nam','086235758','0426695638','Việt Nam','CNB');
insert into BTL1.KHACHHANG values('KH32','Nguyễn Thị Thu Nga',
    '538 Lê Văn Sỹ , Phường 14 , Quận 3','Nữ','086235759','0748427956','Việt Nam','CNB');
insert into BTL1.KHACHHANG values('KH33','Đỗ Huỳnh Ngọc Bích',
    '311/17 Kênh Tân Hóa','Nữ','086235760','0268687695','Việt Nam','CNB');
insert into BTL1.KHACHHANG values('KH34','Nguyễn Ngô Hoàng',
    'B18/23 ấp 3B X.Bình Hưng','Nam','086235761','0935988285','Việt Nam','CNB');
insert into BTL1.KHACHHANG values('KH35','Hoàng Minh Thuý',
    '45 Hồng Hà P02','Nữ','086235762','0122392731','Việt Nam','CNB');
insert into BTL1.KHACHHANG values('KH36','Lê Thị Thiện Hiền',
    '228 Võ văn tần , P.05 , Q.03','Nữ','086235763','0916718725','Việt Nam','CNB');
insert into BTL1.KHACHHANG values('KH37','Trương Quang Thành',
    'Nhà số 7, đường 19, KP2, P. Bình An','Nam','086235764','0891944238','Việt Nam','CNB');
insert into BTL1.KHACHHANG values('KH38','Võ Ngọc Trang',
    '158 Bùi Thị Xuân P03','Nữ','086235765','0348398339','Việt Nam','CNB');
insert into BTL1.KHACHHANG values('KH39','Nguyễn Chí Hiếu',
    '93 Trần Quang Diệu , Phường 13 , Quận 3','Nam','086235766','0116414898','Việt Nam','CNB');
insert into BTL1.KHACHHANG values('KH40','Hồ Văn Sáu',
    '17 Đường 62, KP6, P. Thảo Điền','Nam','086235767','0516422698','Việt Nam','CNB');
insert into BTL1.KHACHHANG values('KH41','Nguyễn Thị Thân',
    'B19-20-21 Đường TMT Kp4 P.Trung Mỹ Tây','Nữ','086235768','0624675344','Việt Nam','CNB');
insert into BTL1.KHACHHANG values('KH42','Ngô Nguyên Đức',
    '388 Đường 26/3 P.BHH','Nam','086235769','0782566964','Việt Nam','CNB');
insert into BTL1.KHACHHANG values('KH43','Trần Thanh Tâm',
    '44 Đồng Đen P14','Nam','086235770','0264188343','Việt Nam','CNB');
insert into BTL1.KHACHHANG values('KH44','Bùi Minh Công',
    '125/198A Lương Thế Vinh, P.Tân Thới Hòa','Nam','086235771','0284143977','Việt Nam','CNB');
insert into BTL1.KHACHHANG values('KH45','Diệp Lệ Dung',
    '207/47/4A Hồ Học Lãm, P.AL','Nữ','086235772','0942692498','Việt Nam','CNB');
insert into BTL1.KHACHHANG values('KH46','Lê Văn Lam',
    '68 Lê Văn Bền P. Tân Kiểng','Nam','086235773','0665227286','Việt Nam','CNB');
insert into BTL1.KHACHHANG values('KH47','Lâm Thị Hồng Nga',
    '327/9 Âu Cơ, P. Phú Trung','Nữ','086235774','0162946752','Việt Nam','CNB');
insert into BTL1.KHACHHANG values('KH48','Nguyễn Văn Tuấn',
    '95/42 Lê Văn Lương Kp1 P. Tân Kiểng','Nam','086235775','0517919875','Việt Nam','CNB');
insert into BTL1.KHACHHANG values('KH49','Lý Chánh Thành',
    '373 Thạch Lam, P.Phú Thạnh','Nam','086235776','0972442961','Việt Nam','CNB');
insert into BTL1.KHACHHANG values('KH50','Nguyễn Thu Hà',
    '449/67 Trường Chinh P.14','Nữ','086235777','0168249278','Việt Nam','CNB');
        
----Insert dữ liệu vào table PHIEU_DK_P
insert into BTL1.PHIEU_DK_P values('PDK01','KH11','NV24','10/06/2006','PA005','CNA');
insert into BTL1.PHIEU_DK_P values('PDK02','KH05','NV19','14/08/2006','PA003','CNA');
insert into BTL1.PHIEU_DK_P values('PDK03','KH15','NV23','10/02/2007','PA014','CNA');
insert into BTL1.PHIEU_DK_P values('PDK04','KH15','NV23','08/08/2007','PA014','CNA');
insert into BTL1.PHIEU_DK_P values('PDK05','KH05','NV14','10/08/2007','PA016','CNA');
insert into BTL1.PHIEU_DK_P values('PDK06','KH06','NV15','13/08/2008','PA003','CNA');
insert into BTL1.PHIEU_DK_P values('PDK07','KH09','NV22','08/06/2009','PA003','CNA');
insert into BTL1.PHIEU_DK_P values('PDK08','KH10','NV23','09/06/2009','PA004','CNA');
insert into BTL1.PHIEU_DK_P values('PDK09','KH11','NV24','10/06/2009','PA005','CNA');
insert into BTL1.PHIEU_DK_P values('PDK10','KH04','NV13','11/08/2009','PA015','CNA');
insert into BTL1.PHIEU_DK_P values('PDK11','KH13','NV10','04/09/2009','PA015','CNA');
insert into BTL1.PHIEU_DK_P values('PDK12','KH05','NV14','12/09/2009','PA016','CNA');
insert into BTL1.PHIEU_DK_P values('PDK13','KH06','NV15','13/09/2009','PA003','CNA');
insert into BTL1.PHIEU_DK_P values('PDK14','KH04','NV13','01/08/2010','PA015','CNA');
insert into BTL1.PHIEU_DK_P values('PDK15','KH14','NV22','07/08/2010','PA016','CNA');
insert into BTL1.PHIEU_DK_P values('PDK16','KH12','NV25','05/09/2010','PA014','CNA');
insert into BTL1.PHIEU_DK_P values('PDK18','KH03','NV08','05/09/2011','PA008','CNA');
insert into BTL1.PHIEU_DK_P values('PDK19','KH12','NV25','05/09/2011','PA014','CNA');
insert into BTL1.PHIEU_DK_P values('PDK20','KH13','NV10','06/09/2011','PA015','CNA');
insert into BTL1.PHIEU_DK_P values('PDK21','KH14','NV22','07/09/2011','PA016','CNA');
insert into BTL1.PHIEU_DK_P values('PDK22','KH15','NV23','08/09/2011','PA014','CNA');
insert into BTL1.PHIEU_DK_P values('PDK23','KH04','NV13','09/09/2011','PA015','CNA');
insert into BTL1.PHIEU_DK_P values('PDK24','KH05','NV19','14/09/2011','PA003','CNA');
insert into BTL1.PHIEU_DK_P values('PDK30','KH02','NV07','19/09/2012','PA002','CNA');
insert into BTL1.PHIEU_DK_P values('PDK41','KH04','NV09','11/10/2015','PA009','CNA');
insert into BTL1.PHIEU_DK_P values('PDK56','KH05','NV10','02/09/2018','PA010','CNA');
insert into BTL1.PHIEU_DK_P values('PDK60','KH08','NV10','05/04/2019','PA019','CNA');
insert into BTL1.PHIEU_DK_P values('PDK61','KH12','NV20','06/04/2019','PA020','CNA');
insert into BTL1.PHIEU_DK_P values('PDK62','KH13','NV21','07/04/2019','PA025','CNA');
insert into BTL1.PHIEU_DK_P values('PDK67','KH07','NV09','04/06/2020','PA012','CNA');
insert into BTL1.PHIEU_DK_P values('PDK69','KH06','NV08','03/11/2020','PA011','CNA');
insert into BTL1.PHIEU_DK_P values('PDK71','KH01','NV06','12/09/2021','PA001','CNA');

insert into BTL1.PHIEU_DK_P values('PDK17','KH49','NV45','25/01/2011','PB030','CNB');
insert into BTL1.PHIEU_DK_P values('PDK25','KH33','NV46','14/10/2011','PB030','CNB');
insert into BTL1.PHIEU_DK_P values('PDK26','KH43','NV42','22/10/2011','PB014','CNB');
insert into BTL1.PHIEU_DK_P values('PDK27','KH31','NV44','24/11/2011','PB023','CNB');
insert into BTL1.PHIEU_DK_P values('PDK28','KH47','NV33','19/03/2012','PB014','CNB');
insert into BTL1.PHIEU_DK_P values('PDK29','KH30','NV32','18/09/2012','PB013','CNB');
insert into BTL1.PHIEU_DK_P values('PDK31','KH48','NV34','20/10/2012','PB015','CNB');
insert into BTL1.PHIEU_DK_P values('PDK32','KH49','NV29','15/03/2013','PB013','CNB');
insert into BTL1.PHIEU_DK_P values('PDK33','KH43','NV30','16/03/2013','PB014','CNB');
insert into BTL1.PHIEU_DK_P values('PDK34','KH49','NV41','21/08/2013','PB013','CNB');
insert into BTL1.PHIEU_DK_P values('PDK35','KH27','NV31','03/10/2013','PB015','CNB');
insert into BTL1.PHIEU_DK_P values('PDK36','KH27','NV43','11/10/2013','PB015','CNB');
insert into BTL1.PHIEU_DK_P values('PDK37','KH26','NV32','17/10/2013','PB012','CNB');
insert into BTL1.PHIEU_DK_P values('PDK38','KH49','NV45','25/03/2014','PB030','CNB');
insert into BTL1.PHIEU_DK_P values('PDK39','KH49','NV41','21/10/2014','PB013','CNB');
insert into BTL1.PHIEU_DK_P values('PDK40','KH43','NV42','22/10/2014','PB014','CNB');
insert into BTL1.PHIEU_DK_P values('PDK42','KH26','NV32','14/10/2015','PB012','CNB');
insert into BTL1.PHIEU_DK_P values('PDK43','KH49','NV29','15/10/2015','PB013','CNB');
insert into BTL1.PHIEU_DK_P values('PDK44','KH43','NV30','16/10/2015','PB014','CNB');
insert into BTL1.PHIEU_DK_P values('PDK45','KH27','NV31','17/10/2015','PB015','CNB');
insert into BTL1.PHIEU_DK_P values('PDK46','KH30','NV32','18/10/2015','PB013','CNB');
insert into BTL1.PHIEU_DK_P values('PDK47','KH47','NV33','19/10/2015','PB014','CNB');
insert into BTL1.PHIEU_DK_P values('PDK48','KH48','NV34','20/10/2015','PB015','CNB');
insert into BTL1.PHIEU_DK_P values('PDK49','KH27','NV43','23/10/2015','PB015','CNB');
insert into BTL1.PHIEU_DK_P values('PDK50','KH31','NV44','24/10/2015','PB023','CNB');
insert into BTL1.PHIEU_DK_P values('PDK51','KH33','NV46','26/10/2015','PB030','CNB');
insert into BTL1.PHIEU_DK_P values('PDK52','KH46','NV31','02/06/2017','PB019','CNB');
insert into BTL1.PHIEU_DK_P values('PDK53','KH47','NV32','03/06/2017','PB020','CNB');
insert into BTL1.PHIEU_DK_P values('PDK54','KH48','NV33','04/07/2017','PB021','CNB');
insert into BTL1.PHIEU_DK_P values('PDK55','KH41','NV29','17/01/2018','PB005','CNB'); 
insert into BTL1.PHIEU_DK_P values('PDK57','KH47','NV31','11/10/2018','PB027','CNB'); 
insert into BTL1.PHIEU_DK_P values('PDK58','KH48','NV26','12/12/2018','PB028','CNB');
insert into BTL1.PHIEU_DK_P values('PDK59','KH29','NV31','13/12/2018','PB029','CNB'); 
insert into BTL1.PHIEU_DK_P values('PDK63','KH42','NV35','18/04/2019','PB008','CNB'); 
insert into BTL1.PHIEU_DK_P values('PDK64','KH50','NV33','06/06/2019','PB025','CNB'); 
insert into BTL1.PHIEU_DK_P values('PDK65','KH28','NV34','07/08/2019','PB026','CNB'); 
insert into BTL1.PHIEU_DK_P values('PDK66','KH49','NV34','05/09/2019','PB024','CNB');
insert into BTL1.PHIEU_DK_P values('PDK68','KH45','NV30','11/10/2020','PB018','CNB');
insert into BTL1.PHIEU_DK_P values('PDK70','KH44','NV29','05/09/2021','PB010','CNB');
insert into BTL1.PHIEU_DK_P values('PDK72','KH39','NV27','15/09/2021','PB003','CNB');
insert into BTL1.PHIEU_DK_P values('PDK73','KH40','NV33','16/09/2021','PB004','CNB'); 
insert into BTL1.PHIEU_DK_P values('PDK74','KH43','NV36','19/09/2021','PB009','CNB'); 

----Insert dữ liệu vào table DICHVU
insert into BTL1.DICHVU values('DV1','COMBO MÁT SA + TẮM HƠI',2000000);
insert into BTL1.DICHVU values('DV2','KARAOKE',500000);
insert into BTL1.DICHVU values('DV3','GIẶT ỦI',200000);
insert into BTL1.DICHVU values('DV4','MÁT SA',800000);
insert into BTL1.DICHVU values('DV5','TẮM HƠI',400000);
insert into BTL1.DICHVU values('DV6','BUFFE',300000); 

----Insert dữ liệu vào table DK_DV
insert into BTL1.DK_DV values('DK_DV01','DV1','PDK01','12/06/2006','CNA');
insert into BTL1.DK_DV values('DK_DV02','DV2','PDK01','12/06/2006','CNA');
insert into BTL1.DK_DV values('DK_DV03','DV1','PDK02','16/08/2006','CNA');
insert into BTL1.DK_DV values('DK_DV04','DV2','PDK03','08/03/2007','CNA');
insert into BTL1.DK_DV values('DK_DV05','DV2','PDK05','12/08/2007','CNA');
insert into BTL1.DK_DV values('DK_DV06','DV3','PDK05','13/08/2007','CNA');
insert into BTL1.DK_DV values('DK_DV07','DV2','PDK04','08/09/2007','CNA');
insert into BTL1.DK_DV values('DK_DV08','DV3','PDK06','13/09/2008','CNA');
insert into BTL1.DK_DV values('DK_DV09','DV5','PDK06','13/09/2008','CNA');
insert into BTL1.DK_DV values('DK_DV10','DV2','PDK09','13/06/2009','CNA');
insert into BTL1.DK_DV values('DK_DV11','DV1','PDK08','19/07/2009','CNA');
insert into BTL1.DK_DV values('DK_DV12','DV2','PDK08','19/07/2009','CNA');
insert into BTL1.DK_DV values('DK_DV13','DV1','PDK07','28/07/2009','CNA');
insert into BTL1.DK_DV values('DK_DV14','DV4','PDK07','29/07/2009','CNA');
insert into BTL1.DK_DV values('DK_DV15','DV1','PDK10','01/09/2009','CNA');
insert into BTL1.DK_DV values('DK_DV16','DV1','PDK11','06/09/2009','CNA');
insert into BTL1.DK_DV values('DK_DV17','DV2','PDK12','15/09/2009','CNA');
insert into BTL1.DK_DV values('DK_DV18','DV2','PDK13','03/10/2009','CNA');
insert into BTL1.DK_DV values('DK_DV19','DV2','PDK14','09/08/2010','CNA');
insert into BTL1.DK_DV values('DK_DV20','DV3','PDK15','09/08/2010','CNA');
insert into BTL1.DK_DV values('DK_DV21','DV1','PDK16','07/09/2010','CNA');
insert into BTL1.DK_DV values('DK_DV23','DV2','PDK20','07/09/2011','CNA');
insert into BTL1.DK_DV values('DK_DV24','DV3','PDK21','07/09/2011','CNA');
insert into BTL1.DK_DV values('DK_DV25','DV2','PDK19','09/09/2011','CNA');
insert into BTL1.DK_DV values('DK_DV26','DV1','PDK22','28/09/2011','CNA');
insert into BTL1.DK_DV values('DK_DV31','DV1','PDK23','17/09/2012','CNA');
insert into BTL1.DK_DV values('DK_DV32','DV2','PDK24','24/09/2012','CNA');
insert into BTL1.DK_DV values('DK_DV44','DV3','PDK41','11/10/2015','CNA');
insert into BTL1.DK_DV values('DK_DV45','DV2','PDK30','17/10/2015','CNA');
insert into BTL1.DK_DV values('DK_DV60','DV2','PDK56','02/09/2018','CNA');
insert into BTL1.DK_DV values('DK_DV61','DV2','PDK18','11/10/2018','CNA');
insert into BTL1.DK_DV values('DK_DV65','DV1','PDK61','06/04/2019','CNA');
insert into BTL1.DK_DV values('DK_DV66','DV1','PDK62','07/04/2019','CNA');
insert into BTL1.DK_DV values('DK_DV69','DV3','PDK60','02/09/2019','CNA');
insert into BTL1.DK_DV values('DK_DV72','DV4','PDK67','04/06/2020','CNA');
insert into BTL1.DK_DV values('DK_DV74','DV3','PDK69','03/11/2020','CNA');
insert into BTL1.DK_DV values('DK_DV76','DV1','PDK71','12/09/2021','CNA');
insert into BTL1.DK_DV values('DK_DV82','DV4','PDK56','22/12/2021','CNA'); 
insert into BTL1.DK_DV values('DK_DV83','DV5','PDK56','22/12/2021','CNA'); 
insert into BTL1.DK_DV values('DK_DV84','DV6','PDK56','22/12/2021','CNA'); 

insert into BTL1.DK_DV values('DK_DV22','DV1','PDK17','15/03/2011','CNB');
insert into BTL1.DK_DV values('DK_DV27','DV2','PDK25','16/10/2011','CNB');
insert into BTL1.DK_DV values('DK_DV28','DV2','PDK26','12/11/2011','CNB');
insert into BTL1.DK_DV values('DK_DV29','DV3','PDK27','21/12/2011','CNB');
insert into BTL1.DK_DV values('DK_DV30','DV1','PDK28','19/05/2012','CNB');
insert into BTL1.DK_DV values('DK_DV33','DV1','PDK29','18/10/2012','CNB');
insert into BTL1.DK_DV values('DK_DV34','DV2','PDK31','20/12/2012','CNB');
insert into BTL1.DK_DV values('DK_DV35','DV2','PDK32','15/03/2013','CNB');
insert into BTL1.DK_DV values('DK_DV36','DV3','PDK33','16/06/2013','CNB');
insert into BTL1.DK_DV values('DK_DV37','DV1','PDK34','21/08/2013','CNB');
insert into BTL1.DK_DV values('DK_DV38','DV1','PDK37','18/10/2013','CNB');
insert into BTL1.DK_DV values('DK_DV39','DV1','PDK35','17/10/2014','CNB');
insert into BTL1.DK_DV values('DK_DV40','DV2','PDK38','20/10/2014','CNB');
insert into BTL1.DK_DV values('DK_DV41','DV1','PDK36','23/10/2014','CNB');
insert into BTL1.DK_DV values('DK_DV42','DV2','PDK40','11/11/2014','CNB');
insert into BTL1.DK_DV values('DK_DV43','DV2','PDK39','18/02/2015','CNB');
insert into BTL1.DK_DV values('DK_DV46','DV1','PDK45','27/10/2015','CNB');
insert into BTL1.DK_DV values('DK_DV47','DV1','PDK51','29/10/2015','CNB');
insert into BTL1.DK_DV values('DK_DV48','DV2','PDK47','03/11/2015','CNB');
insert into BTL1.DK_DV values('DK_DV49','DV1','PDK46','13/11/2015','CNB');
insert into BTL1.DK_DV values('DK_DV50','DV2','PDK48','14/11/2015','CNB');
insert into BTL1.DK_DV values('DK_DV51','DV2','PDK49','25/11/2015','CNB');
insert into BTL1.DK_DV values('DK_DV52','DV1','PDK42','14/12/2015','CNB');
insert into BTL1.DK_DV values('DK_DV53','DV1','PDK43','15/04/2016','CNB');
insert into BTL1.DK_DV values('DK_DV54','DV2','PDK44','19/05/2016','CNB');
insert into BTL1.DK_DV values('DK_DV55','DV1','PDK50','24/12/2016','CNB');
insert into BTL1.DK_DV values('DK_DV56','DV2','PDK52','03/06/2017','CNB');
insert into BTL1.DK_DV values('DK_DV57','DV2','PDK53','04/06/2017','CNB');
insert into BTL1.DK_DV values('DK_DV58','DV2','PDK54','04/08/2017','CNB');
insert into BTL1.DK_DV values('DK_DV59','DV3','PDK55','18/01/2018','CNB');
insert into BTL1.DK_DV values('DK_DV62','DV2','PDK57','11/10/2018','CNB');
insert into BTL1.DK_DV values('DK_DV63','DV2','PDK58','12/12/2018','CNB');
insert into BTL1.DK_DV values('DK_DV64','DV3','PDK59','14/12/2018','CNB');
insert into BTL1.DK_DV values('DK_DV67','DV2','PDK63','19/04/2019','CNB');
insert into BTL1.DK_DV values('DK_DV68','DV2','PDK64','06/07/2019','CNB');
insert into BTL1.DK_DV values('DK_DV70','DV2','PDK65','07/09/2019','CNB');
insert into BTL1.DK_DV values('DK_DV71','DV3','PDK66','07/09/2019','CNB');
insert into BTL1.DK_DV values('DK_DV73','DV5','PDK68','13/10/2020','CNB');
insert into BTL1.DK_DV values('DK_DV75','DV3','PDK70','05/09/2021','CNB');
insert into BTL1.DK_DV values('DK_DV77','DV5','PDK72','15/09/2021','CNB');
insert into BTL1.DK_DV values('DK_DV78','DV5','PDK74','19/09/2021','CNB');
insert into BTL1.DK_DV values('DK_DV79','DV5','PDK72','16/11/2021','CNB');
insert into BTL1.DK_DV values('DK_DV80','DV4','PDK73','19/12/2021','CNB');
insert into BTL1.DK_DV values('DK_DV81','DV3','PDK73','20/12/2021','CNB');

----Insert dữ liệu vào table HOADON
insert into BTL1.HOADON values('HD01','10/02/2007',180,128000000,1,'NV19','KH05','PDK02','CNA');
insert into BTL1.HOADON values('HD02','08/05/2007',87,52700000,2,'NV23','KH15','PDK03','CNA');
insert into BTL1.HOADON values('HD03','12/09/2007',33,20500000,3,'NV14','KH05','PDK05','CNA');
insert into BTL1.HOADON values('HD04','10/06/2008',731,514200000,4,'NV24','KH11','PDK01','CNA');
insert into BTL1.HOADON values('HD05','13/01/2009',153,107700000,5,'NV15','KH06','PDK06','CNA');
insert into BTL1.HOADON values('HD06','28/08/2009',81,59500000,4,'NV22','KH09','PDK07','CNA');
insert into BTL1.HOADON values('HD07','08/09/2009',762,457700000,5,'NV23','KH15','PDK04','CNA');
insert into BTL1.HOADON values('HD08','19/12/2009',193,137600000,4,'NV23','KH10','PDK08','CNA');
insert into BTL1.HOADON values('HD09','01/05/2010',263,159800000,4,'NV13','KH04','PDK10','CNA');
insert into BTL1.HOADON values('HD10','06/05/2010',244,148400000,3,'NV10','KH13','PDK11','CNA');
insert into BTL1.HOADON values('HD11','09/09/2010',39,23900000,3,'NV13','KH04','PDK14','CNA');
insert into BTL1.HOADON values('HD12','05/02/2011',153,93800000,5,'NV25','KH12','PDK16','CNA');
insert into BTL1.HOADON values('HD13','07/02/2011',184,110600000,4,'NV22','KH14','PDK15','CNA');
insert into BTL1.HOADON values('HD14','15/04/2011',580,348500000,2,'NV14','KH05','PDK12','CNA');
insert into BTL1.HOADON values('HD15','06/10/2011',30,18500000,4,'NV10','KH13','PDK20','CNA');
insert into BTL1.HOADON values('HD16','27/11/2011',81,48800000,4,'NV22','KH14','PDK21','CNA');
insert into BTL1.HOADON values('HD18','28/04/2012',233,141800000,5,'NV23','KH15','PDK22','CNA');
insert into BTL1.HOADON values('HD19','17/09/2012',374,226400000,5,'NV13','KH04','PDK23','CNA');
insert into BTL1.HOADON values('HD20','24/09/2012',376,263700000,4,'NV19','KH05','PDK24','CNA');
insert into BTL1.HOADON values('HD26','09/05/2014',977,586700000,4,'NV25','KH12','PDK19','CNA');
insert into BTL1.HOADON values('HD43','03/12/2016',2638,1847100000,4,'NV15','KH06','PDK13','CNA');
insert into BTL1.HOADON values('HD47','13/06/2019',3655,2559000000,3,'NV24','KH11','PDK09','CNA');

insert into BTL1.HOADON values('HD17','15/03/2012',415,168000000,5,'NV45','KH49','PDK17','CNB');
insert into BTL1.HOADON values('HD21','16/10/2012',368,147700000,3,'NV46','KH33','PDK25','CNB');
insert into BTL1.HOADON values('HD22','21/12/2012',393,236000000,4,'NV44','KH31','PDK27','CNB');
insert into BTL1.HOADON values('HD23','18/10/2013',395,239000000,3,'NV32','KH30','PDK29','CNB');
insert into BTL1.HOADON values('HD24','12/01/2014',813,488300000,3,'NV42','KH43','PDK26','CNB');
insert into BTL1.HOADON values('HD25','21/03/2014',212,129200000,3,'NV41','KH49','PDK34','CNB');
insert into BTL1.HOADON values('HD27','17/10/2014',379,229400000,3,'NV31','KH27','PDK35','CNB');
insert into BTL1.HOADON values('HD28','21/10/2014',210,84500000,5,'NV45','KH49','PDK38','CNB');
insert into BTL1.HOADON values('HD29','23/10/2014',377,228200000,5,'NV43','KH27','PDK36','CNB');
insert into BTL1.HOADON values('HD30','11/01/2015',81,49100000,5,'NV42','KH43','PDK40','CNB');
insert into BTL1.HOADON values('HD31','18/02/2015',120,72500000,5,'NV41','KH49','PDK39','CNB');
insert into BTL1.HOADON values('HD32','20/02/2015',853,512300000,4,'NV34','KH48','PDK31','CNB');
insert into BTL1.HOADON values('HD33','19/05/2015',1156,695600000,5,'NV33','KH47','PDK28','CNB');
insert into BTL1.HOADON values('HD34','16/06/2015',822,493400000,4,'NV30','KH43','PDK33','CNB');
insert into BTL1.HOADON values('HD35','14/07/2015',635,383000000,5,'NV32','KH26','PDK37','CNB');
insert into BTL1.HOADON values('HD36','15/08/2015',883,530300000,4,'NV29','KH49','PDK32','CNB');
insert into BTL1.HOADON values('HD37','25/11/2015',33,20300000,5,'NV43','KH27','PDK49','CNB');
insert into BTL1.HOADON values('HD38','29/11/2015',34,15600000,5,'NV46','KH33','PDK51','CNB');
insert into BTL1.HOADON values('HD39','13/12/2015',56,35600000,5,'NV32','KH30','PDK46','CNB');
insert into BTL1.HOADON values('HD40','03/08/2016',289,173900000,5,'NV33','KH47','PDK47','CNB');
insert into BTL1.HOADON values('HD41','14/09/2016',330,198500000,5,'NV34','KH48','PDK48','CNB');
insert into BTL1.HOADON values('HD42','27/10/2016',376,227600000,5,'NV31','KH27','PDK45','CNB');
insert into BTL1.HOADON values('HD44','14/12/2016',427,258200000,4,'NV32','KH26','PDK42','CNB');
insert into BTL1.HOADON values('HD45','24/12/2016',427,258200000,4,'NV44','KH31','PDK50','CNB');
insert into BTL1.HOADON values('HD46','15/04/2019',1278,768800000,4,'NV29','KH49','PDK43','CNB');
insert into BTL1.HOADON values('HD48','19/05/2021',2042,1225700000,3,'NV30','KH43','PDK44','CNB');

-------------------------------------------------------------------------------
-- 2.4 Xem DL đã nhập vào
SELECT * FROM BTL1.LOAIPHONG;
SELECT * FROM BTL1.CHINHANH;
SELECT * FROM BTL1.PHONG
ORDER BY MAPHONG;
SELECT * FROM BTL1.CHUCVU;
SELECT * FROM BTL1.NHANVIEN
ORDER BY MANV;
SELECT * FROM BTL1.KHACHHANG
ORDER BY MAKH;
SELECT * FROM BTL1.PHIEU_DK_P
ORDER BY MAPDK;
SELECT * FROM BTL1.DICHVU;
SELECT * FROM BTL1.DK_DV
ORDER BY MADK_DV;
SELECT * FROM BTL1.HOADON
ORDER BY MAHD;

-------------------------------------------------------------------------------
/* Thống kê phản hồi đánh giá dịch vụ của các khách hàng ở loại phòng 
có TENLP = 'PHÒNG VIP1' ít nhất 1 tuần SONGAY >= 7 và đăng ký sử dụng dịch vụ 
TENDV = 'KARAOKE' tại Chi nhánh Thủ Đức

Thông tin hiển thị gồm: MAKH, TENKH, DANHGIA và cho biết cả thông tin nhân viên 
phụ trách thực hiện thanh toán hóa đơn cho khách hàng: MANV, TENNV
*/

-- Câu truy vấn ban đầu

SELECT KH.MAKH, TENKH, SONGAY, DANHGIA, NV.MANV, TENNV
FROM BTL1.LOAIPHONG LP,
     BTL1.PHONG P,
     BTL1.PHIEU_DK_P PDK_P,
     BTL1.KHACHHANG KH,
     BTL1.DK_DV,
     BTL1.DICHVU DV,
     BTL1.CHINHANH CN,
     BTL1.HOADON HD,
     BTL1.NHANVIEN NV
WHERE LP.MALP = P.MALP AND P.MAPHONG = PDK_P.MAPHONG 
      AND KH.MAKH = PDK_P.MAKH AND DK_DV.MAPDK = PDK_P.MAPDK
      AND DV.MADV = DK_DV.MADV AND HD.MAPDK = PDK_P.MAPDK
      AND NV.MANV = HD.MANV
      AND TENLP = 'PHÒNG VIP1' AND SONGAY >= 7 
      AND TENDV = 'KARAOKE' AND TENCN = 'Chi nhánh Thủ Đức';



-- Câu truy vấn toàn cục

SELECT A.MAKH, TENKH, SONGAY, DANHGIA, MANV, TENNV
FROM
(
	SELECT MAKH, TENKH
	FROM BTL1.KHACHHANG
) A
JOIN
(
	SELECT MAKH, MANV, TENNV, SONGAY, DANHGIA
	FROM
    (
		SELECT MAPHONG
		FROM
        (
			(
                SELECT MALP, MAPHONG
                FROM BTL1.PHONG
			) K
			JOIN
			(
                SELECT MALP
                FROM BTL1.LOAIPHONG
                WHERE TENLP = 'PHÒNG VIP1'
			) I
			ON K.MALP = I.MALP
        )
    ) C
    JOIN
    (
            SELECT MAPHONG, MAKH, TENNV, MANV, SONGAY, DANHGIA
            FROM
			(
                SELECT MAPDK, H.MANV, TENNV, SONGAY, DANHGIA
                FROM
                (
                    SELECT MANV, TENNV
                    FROM
                    (
                        (
                            SELECT MACN, MANV, TENNV
                            FROM BTL1.NHANVIEN
                        ) Q
                        JOIN
                        (
                            SELECT MACN
                            FROM BTL1.CHINHANH
                            WHERE TENCN = 'Chi nhánh Thủ Đức'
                        ) P
                        ON Q.MACN = P.MACN 
                    )
                ) H
                JOIN
                (
                    SELECT MANV, MAPDK, SONGAY, DANHGIA
                    FROM BTL1.HOADON
                    WHERE SONGAY >= 7
                ) M
                ON H.MANV = M.MANV                  
			) F
			JOIN
			(
				SELECT G.MAPDK, MAPHONG, MAKH
				FROM
				(
                    (
                        SELECT MAPDK
                        FROM
                        (
                            (
                                SELECT MADV
                                FROM BTL1.DICHVU
                                WHERE TENDV = 'KARAOKE'
                            ) O
                            JOIN
                            (
                                SELECT MADV, MAPDK
                                FROM BTL1.DK_DV
                            ) N
                            ON O.MADV = N.MADV
                        )
                    )  G
                    JOIN
                    (
                        SELECT MAPDK, MAPHONG, MAKH
                        FROM BTL1.PHIEU_DK_P
                    ) L
                    ON G.MAPDK = L.MAPDK
				) 
			)E
			ON F.MAPDK = E.MAPDK
    ) D
    ON C.MAPHONG = D.MAPHONG
) B
ON A.MAKH = B.MAKH;

