-- VI. Thực hiện các câu truy vấn
/* Query 1. Tài khoản giám đốc:  Tính tổng doanh thu của khách sạn trong 10 năm 
            từ năm 2006 đến năm 2016 */
CONNECT GiamDoc/GiamDoc;

SELECT SUM(TONTIEN) AS TONG_DOANHTHU_TU_NAM2006_2016
FROM
(
    SELECT TONGTIEN
    FROM CNA.HOADON_NV 
    WHERE EXTRACT(YEAR FROM NGAYTHANHTOAN) BETWEEN 2006 AND 2016
    UNION
    SELECT TONGTIEN
    FROM CNB.HOADON_NV@GD_dblink 
    WHERE EXTRACT(YEAR FROM NGAYTHANHTOAN) BETWEEN 2006 AND 2016
);

/* Query 2. Tài khoản giám đốc: Cho biết thông tin khách hàng ở cả 2 chi nhánh 
            đã đăng ký sử dụng tất cả các dịch vụ hiện có tại khách sạn*/
CONNECT GiamDoc/GiamDoc;

SELECT MAKH, TENKH, GIOITINH, SDT
FROM CNA.KHACHHANG KH_A
WHERE NOT EXISTS (
			   SELECT * 
			   FROM CNA.DICHVU DV_A 
                           WHERE NOT EXISTS 
                             (
                                  SELECT *
                                  FROM CNA.DK_DV DK_DV_A JOIN CNA.PHIEU_DK_P PDK_P_A
                                        ON DK_DV_A.MAPDK = PDK_P_A.MAPDK
                                  WHERE DK_DV_A.MADV = DV_A.MADV 
                                        AND PDK_P_A.MAKH = KH_A.MAKH
                             )
                 )
UNION
SELECT MAKH, TENKH, GIOITINH, SDT
FROM CNB.KHACHHANG@GD_dblink KH_B
WHERE NOT EXISTS (
			   SELECT * 
			   FROM CNB.DICHVU@GD_dblink DV_B 
                           WHERE NOT EXISTS 
                             (
                                  SELECT *
                                  FROM CNB.DK_DV@GD_dblink DK_DV_B 
                                        JOIN CNB.PHIEU_DK_P@GD_dblink PDK_P_B
                                            ON DK_DV_B.MAPDK = PDK_P_B.MAPDK
                                  WHERE DK_DV_B.MADV = DV_B.MADV 
                                        AND PDK_P_B.MAKH = KH_B.MAKH
                             )
                  );

/* Query 3. Tài khoản nhân viên: Cho biết dịch vụ đã được đăng ký nhiều hơn 10 lần 
            tại tất cả chi nhánh*/
CONNECT NhanVien/NhanVien;

SELECT DVU_A.MADV, TENDV
FROM CNA.DICHVU DVU_A JOIN CNA.DK_DV DK_DV_A ON DVU_A.MADV = DK_DV_A.MADV
GROUP BY DVU_A.MADV, TENDV
HAVING COUNT(*) >= 10
INTERSECT
SELECT DVU_B.MADV, TENDV
FROM CNB.DICHVU@NV_dblink DVU_B JOIN CNB.DK_DV@NV_dblink DK_DV_B 
    ON DVU_B.MADV = DK_DV_B.MADV
GROUP BY DVU_B.MADV, TENDV
HAVING COUNT(*) >= 10;

/* Query 4. Tài khoản nhân viên:  Cho biết mỗi loại phòng còn có bao nhiêu phòng
            đang trống tại cả hai chi nhánh*/
CONNECT NhanVien/NhanVien;

SELECT MALP, TENLP, COUNT(MAPHONG) AS SOPHONGTRONG
FROM 
(
    SELECT LP_A.MALP AS MALP, TENLP, MAPHONG
    FROM CNA.PHONG P_A JOIN CNA.LOAIPHONG LP_A ON P_A.MALP = LP_A.MALP
    WHERE TINHTRANG = 'TRỐNG'
    UNION
    SELECT LP_B.MALP AS MALP, TENLP, MAPHONG
    FROM CNB.PHONG P_B JOIN CNB.LOAIPHONG LP_B ON P_B.MALP = LP_B.MALP
    WHERE TINHTRANG = 'TRỐNG'
)
GROUP BY MALP, TENLP;

/* Query 5. Truy vấn cục bộ tại chi nhánh A bằng tài khoản quản lý: 
            Cho biết số lượt đánh giá 5 sao cho khách sạn trong năm 2011 */
CONNECT QuanLy/QuanLy;

SELECT COUNT(MAHD) AS SO_DANHGIA_5_SAO
FROM HOADON_QL
WHERE EXTRACT(YEAR FROM NGAYTHANHTOAN) = 2011 AND DANHGIA = 5;
