--Genel bak��
SELECT * 
FROM ibb.dbo.deprem
SELECT * 
FROM ibb.dbo.bina




--Join i�lemi
SELECT * 
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt




------�l�e ve mahalle baz�nda; toplamda ne kadar bina hasar g�rm��?
SELECT d.ilce_adi,d.mahalle_adi, 
(cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi)
as ToplamHasarliBina
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt
ORDER BY ToplamHasarliBina DESC --Olas� deprem senaryosunda en �ok hasar alacak binaya sahip il�e ve mahalleler ilk be�:
								-- AVCILAR - YE��LKENT
								-- K���K�EKMECE - �N�N�
								-- BAH�EL�EVLER - ZAFER
								-- S�L�VR� - SEM�ZKUMLAR
								-- TUZLA - AYDINLI




--
--Toplam bina say�lar� ve toplam hasarl� bina say�lar�n� kar��la�t�rmadan �nce CTE olu�turaca��m
--�l�e ve mahalle baz�nda;
--1) Toplam binalar�n y�zde ka�� hasarl�? 
--CTE;
WITH BinaOranlari (ilce_adi,mahalle_adi,ToplamHasarliBina,ToplamBina)
AS
(
SELECT d.ilce_adi,d.mahalle_adi, 
cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi AS ToplamHasarliBina,
_1980_oncesi+_1980_2000_arasi+_2000_sonrasi AS ToplamBina
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt
)
SELECT ilce_adi,mahalle_adi,ToplamHasarliBina,ToplamBina,
(ToplamHasarliBina*1.0 / ToplamBina)*100 AS HasarliBinaOrani
FROM BinaOranlari
ORDER BY HasarliBinaOrani DESC  --Olas� deprem senaryosunda en �ok hasarl� bina/toplam bina oran�na sahip olacak
								--il�e ve mahalleler ilk be�:
								-- BAKIRK�Y - YE��LYURT				%83 oranda hasarl� bina
								-- BAKIRK�Y - SAKIZA�ACI			%82 oranda hasarl� bina
								-- FAT�H - YED�KULE					%82 oranda hasarl� bina
								-- BAKIRK�Y - YEN�MAHALLE			%81 oranda hasarl� bina
								-- BAKIRK�Y - ATAK�Y 3-4-11. KISIM	%81 oranda hasarl� bina




--2) Ayn� oranlar� il�e baz�nda gruplama
--CTE;
WITH BinaOranlari (ilce_adi,mahalle_adi,ToplamHasarliBina,ToplamBina,HasarliBinaOrani)
AS
(
SELECT d.ilce_adi,d.mahalle_adi, 
cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi AS ToplamHasarliBina,
_1980_oncesi+_1980_2000_arasi+_2000_sonrasi AS ToplamBina,
(cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi)*1.0
/
(_1980_oncesi+_1980_2000_arasi+_2000_sonrasi)*100 AS HasarliBinaOrani
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt
)
SELECT ilce_adi,SUM(ToplamHasarliBina) AS �lceToplamHasarliBina,SUM(ToplamBina) AS �lceToplamBina,
(SUM(ToplamHasarliBina)*1.0/SUM(ToplamBina))*100 AS �lceHasarOrani
FROM BinaOranlari
GROUP BY ilce_adi
ORDER BY �lceHasarOrani DESC --En �ok hasar alan il�eler
							 --olas� bir deprem senaryosunda en �ok hasar alacak ilk 5 il�e:
							 --BAKIRK�Y %78 oranla hasarl�
							 --ADALAR %76 oranla hasarl�
							 --BAH�EL�EVLER %75 oranla hasarl�
							 --ZEYT�NBURNU %72 oranla hasarl�
							 --G�NG�REN %72 oranla hasarl�




------ Binalar�n ya�lar� binalar�n alaca�� hasar� ne kadar etkiliyor?
--1) 1980den eski binalar�n �o�unluk oldu�u il�e ve mahallelerde hasar oranlar� nas�l?
--CTE;
WITH BinaOranlari (ilce_adi,mahalle_adi,ToplamHasarliBina,ToplamBina,HasarliBinaOrani,_1980OncesiOrani)
AS
(
SELECT d.ilce_adi,d.mahalle_adi, 
cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi AS ToplamHasarliBina,
_1980_oncesi+_1980_2000_arasi+_2000_sonrasi AS ToplamBina,
(cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi)*1.0
/
(_1980_oncesi+_1980_2000_arasi+_2000_sonrasi)*100 AS HasarliBinaOrani,
_1980_oncesi*1.0 / (_1980_oncesi+_1980_2000_arasi+_2000_sonrasi +0.0000001)*100 AS _1980OncesiOrani
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt
)
SELECT ilce_adi,mahalle_adi,ToplamHasarliBina,ToplamBina, HasarliBinaOrani,_1980OncesiOrani
FROM BinaOranlari
ORDER BY _1980OncesiOrani DESC -- Eski binalar�n �o�unlukta olmas� al�nacak hasar� kesin bir �ekilde art�r�r
							   -- demek do�ru olmayabilir. �rne�in BEYO�LU - �UKUR b�lgesindeki binalar�n
							   -- %84� 1980 �ncesinden kalma olmas�na ra�men %35 hasar oran�na sahip,
							   -- tam tersi olarak 1980 �ncesinden kalma yap�land�rma bulundurmamas�na ra�men
							   -- %70lerde bile hasar oran� olan b�lgeler bulunmakta.

--2) 2000 ve sonras�nda yap�lan binalar�n �o�unlukta oldu�u b�lgelerde durum nas�l?
--CTE;
WITH BinaOranlari (ilce_adi,mahalle_adi,ToplamHasarliBina,ToplamBina,HasarliBinaOrani,_1980OncesiOrani,_2000SonrasiOrani)
AS
(
SELECT d.ilce_adi,d.mahalle_adi, 
cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi AS ToplamHasarliBina,
_1980_oncesi+_1980_2000_arasi+_2000_sonrasi AS ToplamBina,
(cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi)*1.0
/
(_1980_oncesi+_1980_2000_arasi+_2000_sonrasi)*100 AS HasarliBinaOrani,
_1980_oncesi*1.0 / (_1980_oncesi+_1980_2000_arasi+_2000_sonrasi +0.0000001)*100 AS _1980OncesiOrani,
_2000_sonrasi*1.0 / (_1980_oncesi+_1980_2000_arasi+_2000_sonrasi +0.0000001)*100 AS _2000SonrasiOrani
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt
)
SELECT ilce_adi, mahalle_adi, ToplamHasarliBina, ToplamBina, HasarliBinaOrani, _1980OncesiOrani, _2000SonrasiOrani
FROM BinaOranlari
ORDER BY _2000SonrasiOrani DESC		-- Daha yeni binalar�n �o�unlukta oldu�u b�lgelerde net bir �ekilde hasar�n 
									-- az oldu�unu s�ylemek do�ru de�il, benzer �ekilde farkl� �rnekler bulunmakta.





-- Tam olarak kar��la�t�rma yapabilmek i�in hasar�n t�r� de �nemli, ayn� eski-yeni oranlar�n� binalardaki hasar�n �iddeti ile kar��la�t�rmak gerekli
-- Eski binalar i�in
--CTE;
WITH BinaOranlari (ilce_adi,mahalle_adi,ToplamHasarliBina,ToplamBina,CokHasarliBinaOrani,AgirHasarliBinaOrani,OrtaHasarliBinaOrani,HafifHasarliBinaOrani,HasarliBinaOrani,_1980OncesiOrani,_2000SonrasiOrani)
AS
(
SELECT d.ilce_adi,d.mahalle_adi, 
cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi AS ToplamHasarliBina,
_1980_oncesi+_1980_2000_arasi+_2000_sonrasi AS ToplamBina,

cok_agir_hasarli_bina_sayisi*1.0/ (cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi+0.0000001)*100 AS CokHasarliBinaOrani,
agir_hasarli_bina_sayisi*1.0/ (cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi+0.0000001)*100 AS AgirHasarliBinaOrani,
orta_hasarli_bina_sayisi*1.0/ (cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi+0.0000001)*100 AS OrtaHasarliBinaOrani,
hafif_hasarli_bina_sayisi*1.0/ (cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi+0.0000001)*100 AS HafifHasarliBinaOrani,

(cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi)*1.0
/
(_1980_oncesi+_1980_2000_arasi+_2000_sonrasi+0.0000001)*100 AS HasarliBinaOrani,
_1980_oncesi*1.0 / (_1980_oncesi+_1980_2000_arasi+_2000_sonrasi +0.0000001)*100 AS _1980OncesiOrani,
_2000_sonrasi*1.0 / (_1980_oncesi+_1980_2000_arasi+_2000_sonrasi +0.0000001)*100 AS _2000SonrasiOrani
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt
)
SELECT ilce_adi, mahalle_adi,CokHasarliBinaOrani,AgirHasarliBinaOrani,
OrtaHasarliBinaOrani,HafifHasarliBinaOrani,HasarliBinaOrani,_1980OncesiOrani,_2000SonrasiOrani
FROM BinaOranlari
ORDER BY _1980OncesiOrani DESC  -- Eski binalar�n �o�unluk oldu�u yerlerde �ok A��r hasarl� bina oranlar� genelde daha y�ksekken,
								-- yeni binalar�n �o�unluk oldu�u yerlerde Hafif hasarl� bina oranlar� genelde daha y�ksek.
								-- Bina ya��n�n al�nacak hasar�n �iddetine etkisi oldu�u s�ylenebilir,
								-- fakat ayk�r� �rneklerin de mevcut olmas�n�n da etkisiyle, binan�n ya�� haricinde, 
								-- elimizde bulunmayan bir �ok farkl� de�i�ken
								-- al�nacak hasar�n belirlenmesinde etkili denebilir. (binan�n temeli, kullan�lan materyallerin t�r� ve kalitesi vs.)


								-- En eski binalar�na sahip il�e ve mahalleler ilk be�;
								-- FAT�H - YED�KULE
								-- FAT�H - SARIDEM�R
								-- FAT�H - YAVUZ S�NAN 
								-- FAT�H - KOCA MUSTAFAPA�A
								-- BEYO�LU - �UKUR

								-- En yeni binalara sahip il�e ve mahalleler ilk be�;
								-- �EKMEK�Y - N��ANTEPE
								-- S�L�VR� - KAVAKLI
								-- S�L�VR� - H�RR�YET
								-- ��LE - DO�ANCILI
								-- TUZLA - AKFIRAT


------ Binalar�n �ok katl� olmas� al�nan hasar� etkiliyor mu?
-- 9-19 katl� binalar�n oldu�u b�lgelerde hasar �ok mu az m�?
--CTE;
WITH BinaOranlari (ilce_adi,mahalle_adi,ToplamHasarliBina,ToplamBina,HasarliBinaOrani,_9_19_kat_arasi)
AS
(
SELECT d.ilce_adi,d.mahalle_adi, 
cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi AS ToplamHasarliBina,
_1980_oncesi+_1980_2000_arasi+_2000_sonrasi AS ToplamBina,
(cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi)*1.0
/
(_1980_oncesi+_1980_2000_arasi+_2000_sonrasi)*100 AS HasarliBinaOrani,
_9_19_kat_arasi
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt
)
SELECT *
FROM BinaOranlari
WHERE _9_19_kat_arasi > 0 -- �o�u b�lgede 9 - 19 kat aras� bina yok, sadece olan b�lgelere bak�l�yor
ORDER BY HasarliBinaOrani DESC		-- Yine ayk�r� g�zlemler bulunmakla beraber,
									-- hasarl� bina oran� y�ksek b�lgelerde, fazla say�da �ok katl� bina olmad��� s�ylenebilir,
									-- bu durum �ok katl� binalar�n daha yeni teknolojik y�ntemlerle/ara�larla yap�l�p
									-- daha dayan�kl� olmalar�na ba�lanabilir.