--Genel bakýþ
SELECT * 
FROM ibb.dbo.deprem
SELECT * 
FROM ibb.dbo.bina




--Join iþlemi
SELECT * 
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt




------Ýlçe ve mahalle bazýnda; toplamda ne kadar bina hasar görmüþ?
SELECT d.ilce_adi,d.mahalle_adi, 
(cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi)
as ToplamHasarliBina
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt
ORDER BY ToplamHasarliBina DESC --Olasý deprem senaryosunda en çok hasar alacak binaya sahip ilçe ve mahalleler ilk beþ:
								-- AVCILAR - YEÞÝLKENT
								-- KÜÇÜKÇEKMECE - ÝNÖNÜ
								-- BAHÇELÝEVLER - ZAFER
								-- SÝLÝVRÝ - SEMÝZKUMLAR
								-- TUZLA - AYDINLI




--
--Toplam bina sayýlarý ve toplam hasarlý bina sayýlarýný karþýlaþtýrmadan önce CTE oluþturacaðým
--Ýlçe ve mahalle bazýnda;
--1) Toplam binalarýn yüzde kaçý hasarlý? 
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
ORDER BY HasarliBinaOrani DESC  --Olasý deprem senaryosunda en çok hasarlý bina/toplam bina oranýna sahip olacak
								--ilçe ve mahalleler ilk beþ:
								-- BAKIRKÖY - YEÞÝLYURT				%83 oranda hasarlý bina
								-- BAKIRKÖY - SAKIZAÐACI			%82 oranda hasarlý bina
								-- FATÝH - YEDÝKULE					%82 oranda hasarlý bina
								-- BAKIRKÖY - YENÝMAHALLE			%81 oranda hasarlý bina
								-- BAKIRKÖY - ATAKÖY 3-4-11. KISIM	%81 oranda hasarlý bina




--2) Ayný oranlarý ilçe bazýnda gruplama
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
SELECT ilce_adi,SUM(ToplamHasarliBina) AS ÝlceToplamHasarliBina,SUM(ToplamBina) AS ÝlceToplamBina,
(SUM(ToplamHasarliBina)*1.0/SUM(ToplamBina))*100 AS ÝlceHasarOrani
FROM BinaOranlari
GROUP BY ilce_adi
ORDER BY ÝlceHasarOrani DESC --En çok hasar alan ilçeler
							 --olasý bir deprem senaryosunda en çok hasar alacak ilk 5 ilçe:
							 --BAKIRKÖY %78 oranla hasarlý
							 --ADALAR %76 oranla hasarlý
							 --BAHÇELÝEVLER %75 oranla hasarlý
							 --ZEYTÝNBURNU %72 oranla hasarlý
							 --GÜNGÖREN %72 oranla hasarlý




------ Binalarýn yaþlarý binalarýn alacaðý hasarý ne kadar etkiliyor?
--1) 1980den eski binalarýn çoðunluk olduðu ilçe ve mahallelerde hasar oranlarý nasýl?
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
ORDER BY _1980OncesiOrani DESC -- Eski binalarýn çoðunlukta olmasý alýnacak hasarý kesin bir þekilde artýrýr
							   -- demek doðru olmayabilir. Örneðin BEYOÐLU - ÇUKUR bölgesindeki binalarýn
							   -- %84ü 1980 öncesinden kalma olmasýna raðmen %35 hasar oranýna sahip,
							   -- tam tersi olarak 1980 öncesinden kalma yapýlandýrma bulundurmamasýna raðmen
							   -- %70lerde bile hasar oraný olan bölgeler bulunmakta.

--2) 2000 ve sonrasýnda yapýlan binalarýn çoðunlukta olduðu bölgelerde durum nasýl?
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
ORDER BY _2000SonrasiOrani DESC		-- Daha yeni binalarýn çoðunlukta olduðu bölgelerde net bir þekilde hasarýn 
									-- az olduðunu söylemek doðru deðil, benzer þekilde farklý örnekler bulunmakta.





-- Tam olarak karþýlaþtýrma yapabilmek için hasarýn türü de önemli, ayný eski-yeni oranlarýný binalardaki hasarýn þiddeti ile karþýlaþtýrmak gerekli
-- Eski binalar için
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
ORDER BY _1980OncesiOrani DESC  -- Eski binalarýn çoðunluk olduðu yerlerde Çok Aðýr hasarlý bina oranlarý genelde daha yüksekken,
								-- yeni binalarýn çoðunluk olduðu yerlerde Hafif hasarlý bina oranlarý genelde daha yüksek.
								-- Bina yaþýnýn alýnacak hasarýn þiddetine etkisi olduðu söylenebilir,
								-- fakat aykýrý örneklerin de mevcut olmasýnýn da etkisiyle, binanýn yaþý haricinde, 
								-- elimizde bulunmayan bir çok farklý deðiþken
								-- alýnacak hasarýn belirlenmesinde etkili denebilir. (binanýn temeli, kullanýlan materyallerin türü ve kalitesi vs.)


								-- En eski binalarýna sahip ilçe ve mahalleler ilk beþ;
								-- FATÝH - YEDÝKULE
								-- FATÝH - SARIDEMÝR
								-- FATÝH - YAVUZ SÝNAN 
								-- FATÝH - KOCA MUSTAFAPAÞA
								-- BEYOÐLU - ÇUKUR

								-- En yeni binalara sahip ilçe ve mahalleler ilk beþ;
								-- ÇEKMEKÖY - NÝÞANTEPE
								-- SÝLÝVRÝ - KAVAKLI
								-- SÝLÝVRÝ - HÜRRÝYET
								-- ÞÝLE - DOÐANCILI
								-- TUZLA - AKFIRAT


------ Binalarýn çok katlý olmasý alýnan hasarý etkiliyor mu?
-- 9-19 katlý binalarýn olduðu bölgelerde hasar çok mu az mý?
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
WHERE _9_19_kat_arasi > 0 -- çoðu bölgede 9 - 19 kat arasý bina yok, sadece olan bölgelere bakýlýyor
ORDER BY HasarliBinaOrani DESC		-- Yine aykýrý gözlemler bulunmakla beraber,
									-- hasarlý bina oraný yüksek bölgelerde, fazla sayýda çok katlý bina olmadýðý söylenebilir,
									-- bu durum çok katlý binalarýn daha yeni teknolojik yöntemlerle/araçlarla yapýlýp
									-- daha dayanýklý olmalarýna baðlanabilir.