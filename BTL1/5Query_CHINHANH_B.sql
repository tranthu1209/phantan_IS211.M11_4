-- VI. Thực hiện các câu truy vấn
/* Query 1. Tài khoản giám đốc:  Cho biết thông tin nhân viên mang lại doanh thu nhiều nhất ở từng chi nhánh*/
CONNECT GiamDoc/GiamDoc;

SELECT NV_B.MANV, TENNV, TENCN
FROM CNB.NHANVIEN NV_B JOIN CNB.HOADON_NV HD_NV_B ON NV_B.MANV = HD_NV_B.MANV
	JOIN CNB.CHINHANH CN_B ON CN_B.MACN = NV_B.MACN
GROUP BY NV_B.MANV, TENNV, TENCN
HAVING SUM(TONGTIEN) >= ALL 
		(
			SELECT SUM(TONGTIEN)
			FROM CNB.NHANVIEN NV_B JOIN CNB.HOADON_NV HD_NV_B 
					ON NV_B.MANV = HD_NV_B.MANV
				JOIN CNB.CHINHANH CN_B ON CN_B.MACN = NV_B.MACN
			GROUP BY NV_B.MANV, TENNV, TENCN
		)
UNION
SELECT NV_A.MANV, TENNV, TENCN
FROM CNA.NHANVIEN@GD_dblink NV_A JOIN CNA.HOADON_NV@GD_dblink HD_NV_A 
		ON NV_A.MANV = HD_NV_A.MANV
	JOIN CNA.CHINHANH@GD_dblink CN_A ON CN_A.MACN = NV_A.MACN
GROUP BY NV_A.MANV, TENNV, TENCN
HAVING SUM(TONGTIEN) >= ALL 
		(
			SELECT SUM(TONGTIEN)
			FROM CNA.NHANVIEN@GD_dblink NV_A JOIN CNA.HOADON_NV@GD_dblink HD_NV_A 
					ON NV_A.MANV = HD_NV_A.MANV
				JOIN CNA.CHINHANH@GD_dblink CN_A ON CN_A.MACN = NV_A.MACN
			GROUP BY NV_A.MANV, TENNV, TENCN
		);

/* Query 2. Tài khoản giám đốc: Cho biết thông tin dịch vụ được đăng ký tại chi 
            chi nhánh A nhưng không được đăng ký tại chi nhánh B */
CONNECT GiamDoc/GiamDoc;

SELECT DISTINCT DV_A.MADV, TENDV
FROM CNA.DICHVU@GD_dblink DV_A JOIN CNA.DK_DV@GD_dblink DK_DV_A 
        ON DV_A.MADV = DK_DV_A.MADV
MINUS       
SELECT DISTINCT DV_B.MADV, TENDV
FROM CNB.DICHVU DV_B JOIN CNB.DK_DV DK_DV_B ON DV_B.MADV = DK_DV_B.MADV;

/* Query 3. Tài khoản nhân viên: Cho biết loại phòng nào được đăng ký nhiều nhất
            ở cả 2 chi nhánh */
CONNECT NhanVien/NhanVien;

SELECT MALP, TENLP
FROM
(
    SELECT LP_B.MALP AS MALP, TENLP, P_B.MAPHONG
    FROM CNB.LOAIPHONG LP_B JOIN CNB.PHONG P_B ON LP_B.MALP = P_B.MALP
            JOIN CNB.PHIEU_DK_P PDK_P_B ON PDK_P_B.MAPHONG = P_B.MAPHONG
    UNION
    SELECT LP_A.MALP AS MALP, TENLP, P_A.MAPHONG
    FROM CNA.LOAIPHONG@NV_dblink LP_A JOIN CNA.PHONG@NV_dblink P_A 
                ON LP_A.MALP = P_A.MALP
            JOIN CNA.PHIEU_DK_P@NVdblink PDK_P_A ON PDK_P_A.MAPHONG = P_A.MAPHONG
)
GROUP BY MALP, TENLP
HAVING COUNT(*) >= ALL
        (
            SELECT COUNT(*)
            FROM
            (
                SELECT LP_B.MALP AS MALP, TENLP, P_B.MAPHONG
                FROM CNB.LOAIPHONG LP_B JOIN CNB.PHONG P_B ON LP_B.MALP = P_B.MALP
                     JOIN CNB.PHIEU_DK_P PDK_P_B ON PDK_P_B.MAPHONG = P_B.MAPHONG
                UNION
                SELECT LP_A.MALP AS MALP, TENLP, P_A.MAPHONG
                FROM CNA.LOAIPHONG@NV_dblink LP_A JOIN CNA.PHONG@NV_dblink P_A 
                        ON LP_A.MALP = P_A.MALP
                    JOIN CNA.PHIEU_DK_P@NVdblink PDK_P_A ON PDK_P_A.MAPHONG = P_A.MAPHONG
            )
            GROUP BY MALP, TENLP
        );

/* Query 4. Tài khoản nhân viên: Tính doanh thu trung bình theo từng năm của cả 
            2 chi nhánh */
CONNECT NhanVien/NhanVien;

SELECT THANG, AVG(TONGTIEN) AS DOANHTHU_TB
FROM 
(
    SELECT EXTRACT(MONTH FROM NGAYTHANHTOAN) AS THANG, TONGTIEN
    FROM CNB.HOADON_NV  
    UNION
    SELECT EXTRACT(MONTH FROM NGAYTHANHTOAN) AS THANG, TONGTIEN
    FROM CNA.HOADON_NV@NV_dblink
)
GROUP BY THANG
ORDER BY THANG;

/* Query 5. Truy vấn cục bộ tại chi nhánh B bằng tài khoản quản lý: Cho biết 
            thông tin khách hàng và phản hồi đánh giá của khách hàng đã đăng ký 
            dịch vụ KARAOKE vào tháng 10 hằng năm*/
CONNECT QuanLy/QuanLy;

SELECT KH.MAKH, TENKH, DANHGIA, NGAYDK_DV
FROM CNB.KHACHHANG KH JOIN CNB.PHIEU_DK_P PDK_P ON KH.MAKH = PDK_P.MAKH
        JOIN CNB.HOADON_QL HD_QL ON HD_QL.MAPDK = PDK_P.MAPDK
        JOIN CNB.DK_DV DK_DV ON DK_DV.MAPDK = PDK_P.MAPDK
        JOIN CNB.DICHVU DVU ON DVU.MADV = DK_DV.MADV
WHERE EXTRACT(MONTH FROM NGAYDK_DV) = 10 AND TENDV = 'KARAOKE';

