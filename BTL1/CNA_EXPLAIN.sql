-- Câu truy vấn tối ưu cuối cùng trên phân mảnh
CONNECT CNA/CNA;


SELECT A.MAKH, TENKH, SONGAY, DANHGIA, MANV, TENNV
FROM
(
	SELECT MAKH, TENKH
	FROM CNA.KHACHHANG
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
                FROM CNA.PHONG
			) K
			JOIN
			(
                SELECT MALP
                FROM CNA.LOAIPHONG
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
                    FROM CNA.NHANVIEN
                ) H
                JOIN
                (
                    SELECT MANV, MAPDK, SONGAY, DANHGIA
                    FROM
                    (
                        (
                            SELECT MAHD, MANV, MAPDK, SONGAY
                            FROM CNA.HOADON_NV
                            WHERE SONGAY >= 7
                        ) R
                        JOIN
                        (
                            SELECT MAHD, DANHGIA
                            FROM CNA.HOADON_QL
                        ) S
                        ON R.MAHD = S.MAHD
                    )
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
                                FROM CNA.DICHVU
                                WHERE TENDV = 'KARAOKE'
                            ) O
                            JOIN
                            (
                                SELECT MADV, MAPDK
                                FROM CNA.DK_DV
                            ) N
                            ON O.MADV = N.MADV
                        )
                    )  G
                    JOIN
                    (
                        SELECT MAPDK, MAPHONG, MAKH
                        FROM CNA.PHIEU_DK_P
                    ) L
                    ON G.MAPDK = L.MAPDK
				) 
			)E
			ON F.MAPDK = E.MAPDK
    ) D
    ON C.MAPHONG = D.MAPHONG
) B
ON A.MAKH = B.MAKH;