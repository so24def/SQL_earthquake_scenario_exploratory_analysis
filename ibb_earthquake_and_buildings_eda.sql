--Genel bakış
SELECT * 
FROM ibb.dbo.deprem
SELECT * 
FROM ibb.dbo.bina



--Join işlemi
-- iki tabloda da id kolonunu primary key seçerek import etmiştim
-- mahalle_koy_uavt ve mahalle_uavt kolonları ise ilçelerin ulusal adreslerini içeriyor ve
-- iki tabloda da ortak
SELECT * 
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt



--Tek değişkenli inceleme
SELECT *
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt
--ORDER BY cok_agir_hasarli_bina_sayisi DESC
--ORDER BY agir_hasarli_bina_sayisi DESC
--ORDER BY orta_hasarli_bina_sayisi DESC
--ORDER BY hafif_hasarli_bina_sayisi DESC
ORDER BY can_kaybi_sayisi DESC



-- Hiç can kaybı olmayan bölgeler? İlçe-mahalle bazında
SELECT d.ilce_adi,d.mahalle_adi,d.can_kaybi_sayisi
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b
ON d.mahalle_koy_uavt = b.mahalle_uavt
WHERE can_kaybi_sayisi = 0

-- Hiç bir mahallesinde bile can kaybı olmayan, tamamında can kaybı yaşanmayan ilçeler?

SELECT d.ilce_adi,SUM(d.can_kaybi_sayisi) AS İlceTopCanKaybi
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b
ON d.mahalle_koy_uavt = b.mahalle_uavt
GROUP BY d.ilce_adi
HAVING SUM(d.can_kaybi_sayisi) = 0						---- ARNAVUTKÖY VE ŞİLE ilçelerinin HİÇ BİR mahallesinde can kaybı
										--  yaşanmamış, bu kriter bakımından en güvenli ilçeler olduğu söylenebilir.






--Tek değişkenli inceleme, ilçe bazında gruplu
SELECT d.ilce_adi, 
SUM(cok_agir_hasarli_bina_sayisi) AS İlceTopCokAgirHasar,
SUM(agir_hasarli_bina_sayisi) AS İlceTopAgirHasar,
SUM(orta_hasarli_bina_sayisi) AS İlceTopOrtaHasar,
SUM(hafif_hasarli_bina_sayisi) AS İlceTopHafifHasar,
SUM(can_kaybi_sayisi) AS İlceTopCanKaybi,
SUM(gecici_barinma) AS İlceTopSiginak
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt
GROUP BY d.ilce_adi
--ORDER BY İlceTopCokAgirHasar DESC 		-- FATİH, KÜÇÜKÇEKMECE, BAĞCILAR, BAHÇELİEVLER, BAKIRKÖY...
--ORDER BY İlceTopAgirHasar DESC 		-- FATİH, KÜÇÜKÇEKMECE, BAĞCILAR, ESENYURT, SİLİVRİ...
--ORDER BY İlceTopOrtaHasar DESC 		-- FATİH, KÜÇÜKÇEKMECE, BAĞCILAR, ESENYURT, SİLİVRİ...
--ORDER BY İlceTopHafifHasar DESC 		-- FATİH, BAĞCILAR, ESENYURT, KÜÇÜKÇEKMECE, PENDİK...
--ORDER BY İlceTopCanKaybi DESC 		-- BAHÇELİEVLER, KÜÇÜKÇEKMECE, FATİH, BAĞCILAR, BAKIRKÖY...
ORDER BY İlceTopSiginak DESC 			-- KÜÇÜKÇEKMECE, ESENYURT, BAHÇELİEVLER, BAĞCILAR, FATİH...
								
								
								-- Olası deprem senaryosunda en çok can kaybı yaşayacak ve hasar alacak bölgelerin
								-- FATİH, KÜÇÜKÇEKMECE, BAĞCILAR, BAHÇELİEVLER olacağı söylenebilir.


--------------------	İki değişkenli inceleme

------İlçe ve mahalle bazında; toplamda ne kadar bina hasar görmüş?
SELECT d.ilce_adi,d.mahalle_adi, 
(cok_agir_hasarli_bina_sayisi+agir_hasarli_bina_sayisi+orta_hasarli_bina_sayisi+hafif_hasarli_bina_sayisi)
as ToplamHasarliBina
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt
ORDER BY ToplamHasarliBina DESC 		--Olası deprem senaryosunda en çok hasar alacak binaya sahip ilçe ve mahalleler ilk beş:
								-- AVCILAR - YEŞİLKENT
								-- KÜÇÜKÇEKMECE - İNÖNÜ
								-- BAHÇELİEVLER - ZAFER
								-- SİLİVRİ - SEMİZKUMLAR
								-- TUZLA - AYDINLI




--
--Toplam bina sayıları ve toplam hasarlı bina sayılarını karşılaştırmadan önce CTE oluşturacağım
--İlçe ve mahalle bazında;
--1) Toplam binaların yüzde kaçı hasarlı? 
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
ORDER BY HasarliBinaOrani DESC  	--Olası deprem senaryosunda en çok (hasarlı bina/toplam bina) oranına sahip olacak
					--ilçe ve mahalleler ilk beş:
					-- BAKIRKÖY - YEŞİLYURT			%83 oranda hasarlı bina
					-- BAKIRKÖY - SAKIZAĞACI		%82 oranda hasarlı bina
					-- FATİH - YEDİKULE			%82 oranda hasarlı bina
					-- BAKIRKÖY - YENİMAHALLE		%81 oranda hasarlı bina
					-- BAKIRKÖY - ATAKÖY 3-4-11. KISIM	%81 oranda hasarlı bina




--2) Aynı oranları ilçe bazında gruplama
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
SELECT ilce_adi,SUM(ToplamHasarliBina) AS İlceToplamHasarliBina,SUM(ToplamBina) AS İlceToplamBina,
(SUM(ToplamHasarliBina)*1.0/SUM(ToplamBina))*100 AS İlceHasarOrani
FROM BinaOranlari
GROUP BY ilce_adi
ORDER BY İlceHasarOrani DESC --En çok hasar alan ilçeler
							 
							 --Olası bir deprem senaryosunda en çok hasar alacak ilk 5 ilçe:
							 --BAKIRKÖY 	%78 oranla hasarlı
							 --ADALAR 	%76 oranla hasarlı
							 --BAHÇELİEVLER %75 oranla hasarlı
							 --ZEYTİNBURNU 	%72 oranla hasarlı
							 --GÜNGÖREN 	%72 oranla hasarlı




------ Binaların yaşları binaların alacağı hasarı ne kadar etkiliyor?

--1) 1980den eski binaların çoğunluk olduğu ilçe ve mahallelerde hasar oranları nasıl?
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
ORDER BY _1980OncesiOrani DESC
							   -- Eski binaların çoğunlukta olması alınacak hasarı kesin bir şekilde artırır
							   -- demek doğru olmayabilir. Örneğin BEYOĞLU - ÇUKUR bölgesindeki binaların
							   -- %84ü 1980 öncesinden kalma olmasına rağmen %35 hasar oranına sahip,
							   -- tam tersi olarak 1980 öncesinden kalma yapılandırma bulundurmamasına rağmen
							   -- %70lerde bile hasar oranı olan bölgeler bulunmakta.


--2) 2000 ve sonrasında yapılan binaların çoğunlukta olduğu bölgelerde durum nasıl?

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
ORDER BY _2000SonrasiOrani DESC						-- Daha yeni binaların çoğunlukta olduğu bölgelerde net bir şekilde hasarın 
									-- az olduğunu söylemek doğru değil, benzer şekilde farklı örnekler bulunmakta.





-- Tam olarak karşılaştırma yapabilmek için hasarın türü de önemli, aynı eski-yeni oranlarını binalardaki hasarın şiddeti ile karşılaştırmak gerekli
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
--ORDER BY _1980OncesiOrani DESC  
ORDER BY _2000SonrasiOrani DESC	
								-- Eski binaların çoğunluk olduğu yerlerde Çok Ağır hasarlı bina oranları genelde daha yüksekken,
								-- yeni binaların çoğunluk olduğu yerlerde Hafif hasarlı bina oranları genelde daha yüksek.
								-- Bina yaşının alınacak hasarın şiddetine etkisi olduğu söylenebilir,
								-- fakat aykırı örneklerin de mevcut olmasının da etkisiyle, binanın yaşı haricinde, 
								-- elimizde bulunmayan bir çok farklı değişken
								-- alınacak hasarın belirlenmesinde etkili denebilir. (binanın temeli, kullanılan materyallerin türü ve kalitesi vs.)


								-- En eski binalarına sahip ilçe ve mahalleler ilk beş;
								-- FATİH - YEDİKULE
								-- FATİH - SARIDEMİR
								-- FATİH - YAVUZ SİNAN 
								-- FATİH - KOCA MUSTAFAPAŞA
								-- BEYOĞLU - ÇUKUR

								-- En yeni binalara sahip ilçe ve mahalleler ilk beş;
								-- ÇEKMEKÖY - NİŞANTEPE
								-- SİLİVRİ - KAVAKLI
								-- SİLİVRİ - HÜRRİYET
								-- ŞİLE - DOĞANCILI
								-- TUZLA - AKFIRAT


------ Binaların çok katlı olması alınan hasarı etkiliyor mu?
-- 9-19 katlı binaların olduğu bölgelerde hasar çok mu az mı?
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
WHERE _9_19_kat_arasi > 0	-- çoğu bölgede 9 - 19 kat arası bina yok, sadece olan bölgelere bakılıyor
--ORDER BY HasarliBinaOrani DESC
ORDER BY _9_19_kat_arasi DESC

									-- Yine aykırı gözlemler bulunmakla beraber,
									-- hasarlı bina oranı yüksek bölgelerde, fazla sayıda çok katlı bina olmadığı söylenebilir,
									-- bu durum çok katlı binaların daha yeni teknolojik yöntemlerle/araçlarla yapılmaları gerekliliğine
									-- ve daha dayanıklı olmalarına bağlanabilir.




---- Binaların yaşları ile deprem durumlarında yaşanan tesisat sorunlarının bir ilişkisi var mı?
SELECT d.ilce_adi,
SUM(dogalgaz_boru_hasari) AS İlceTopHasarliDogalgaz,
SUM(icme_suyu_boru_hasari) AS İlceTopHasarliİcmeSuyu,
SUM(atik_su_boru_hasari) AS İlceTopHasarliAtikSuyu,
SUM(_1980_oncesi) AS İlceTop1980,
SUM(_1980_2000_arasi) AS İlceTop1980_2000,
SUM(_2000_sonrasi) AS İlceTop2000,
SUM(dogalgaz_boru_hasari+icme_suyu_boru_hasari+atik_su_boru_hasari) AS İlceTopTesisatHasari
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt
GROUP BY d.ilce_adi
ORDER BY İlceTop1980 DESC 		-- Eski binaların olduğu bölgelerdeki toplam hasarlı tesisat; 72, 20, 25, 27, 32...
--ORDER BY İlceTop2000 DESC		-- Yeni binaların olduğu bölgelerdeki toplam hasarlı tesisat; 86, 40, 64, 25, 115...
--ORDER BY İlceTop1980_2000 DESC -	- Yeni binaların çoğunlukta olduğu bazı bölgelerde, 1980-2000 arası binalar da çoğunlukta
					-- ve bu durum karışıklık yaratıyor. 

							-- Yeni binaların çoğunlukta olduğu ilçelerde tesisat sorunları daha fazla görünüyor 
							-- olsa da sorunun yeni binalardan mı yoksa 1980-2000 arası binalardan mı kaynaklandığı
							-- net ayırt edilemiyor.


----Bunun için, yeni bina sayısının eski binaların sayıları toplamından kesinlikle fazla olduğu bölgelere bakılmalı;
SELECT d.ilce_adi,
SUM(dogalgaz_boru_hasari) AS İlceTopHasarliDogalgaz,
SUM(icme_suyu_boru_hasari) AS İlceTopHasarliİcmeSuyu,
SUM(atik_su_boru_hasari) AS İlceTopHasarliAtikSuyu,
SUM(_1980_oncesi) AS İlceTop1980,
SUM(_1980_2000_arasi) AS İlceTop1980_2000,
SUM(_2000_sonrasi) AS İlceTop2000,
SUM(dogalgaz_boru_hasari+icme_suyu_boru_hasari+atik_su_boru_hasari) AS İlceTopTesisatHasari
FROM ibb.dbo.deprem d
LEFT JOIN ibb.dbo.bina b 
ON d.mahalle_koy_uavt = b.mahalle_uavt
GROUP BY d.ilce_adi
HAVING (SUM(_2000_sonrasi)*1.0/SUM(_1980_2000_arasi + _1980_oncesi)) > 1	-- Eski binalar toplamının yeni bina sayısına eşit olmadığı, 
										-- yeni bina sayısının 1 kattan daha fazla olduğu kısım ile sınırlandırma
ORDER BY (SUM(_2000_sonrasi)*1.0/SUM(_1980_2000_arasi + _1980_oncesi)) DESC
																		 -- Sıralama bu (yeni binalar/eski binalar toplamı) oranının gittikçe azaldığı sırada,
																		 -- yani aşağı indikçe eski binalar toplamı yeni binalar toplamına yaklaşıyor.
																		 -- (Yeni binalar/eski binalar toplamı) oranı azaldıkça da hasar artıyor.
																		 -- Yani, yine kesin bir yorum yapmak pek mümkün olmasa da yeni binaların çok hasarlı tesisata
																		 -- sebep olmasının mümkün olmadığı, sorunun her bölgede en az yeni binalar kadar 
																		 -- eski binaların da olmasından kaynaklandığı söylenebilir.
 
