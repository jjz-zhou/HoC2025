# House of Councillors Elections 2025
# Author: Jiajia Zhou
# Version: July 23, 2025



# Load libraries ----------------------------------------------------------

library(httr)
library(tidyverse)
library(xml2)



# Download files from NHK -------------------------------------------------

# Results
# https://www.nhk.or.jp/senkyo-data/database/sangiin/2025/00/20785/xml/ka/emap.xml

r1 <- GET("https://www.nhk.or.jp/senkyo-data/database/sangiin/2025/00/20785/xml/ka/emap.xml",
         user_agent("Mozilla/5.0"), config(followlocation = TRUE))

writeBin(content(r1, "raw"), "data/results.xml")

# Candidate info
# https://www.nhk.or.jp/senkyo-data/database/sangiin/2025/00/20785/xml/ka/khidx.csv

r2 <- GET("https://www.nhk.or.jp/senkyo-data/database/sangiin/2025/00/20785/xml/ka/khidx.csv",
          user_agent("Mozilla/5.0"), config(followlocation = TRUE))

writeBin(content(r2, "raw"), "data/candidate_id.csv")

# Party info
r3 <- GET("https://www3.nhk.or.jp/senkyo-data/database/sangiin/2025/00/search/stindex.csv",
    user_agent("Mozilla/5.0"), config(followlocation = TRUE))

writeBin(content(r3, "raw"), "data/stindex.csv")

# Prefecture info
r4 <- GET("https://www3.nhk.or.jp/senkyo-data/database/sangiin/2025/00/search/sindex.csv",
          user_agent("Mozilla/5.0"), config(followlocation = TRUE))

writeBin(content(r4, "raw"), "data/sindex.csv")

rm(list=ls())



# Wrangling ---------------------------------------------------------------

# Candidate info
cand_id <- read.csv("data/candidate_id.csv",header=F) |>
  dplyr::select(-c(V1,V9))

colnames(cand_id) <- c("khId","name_kanji","name_kana", "partyId", "senkId",
                       "hirei","cand_exp")


# Party id
stindex <- read.csv("data/stindex.csv",header=F,row.names = 1)
colnames(stindex)[c(1,2,4)] <- c("partyId","partyNm_short","partyNm")

# Cand-party
cand_info <- left_join(cand_id,stindex[,c("partyId","partyNm_short","partyNm")],by="partyId") |>
  select(-senkId)

# Pref id
# total units: 45
# tottori-shimane (code:31); ehime-kochi (code:38)
sindex <- read.csv("data/sindex.csv",header=F) |>
  dplyr::select(-c(1,2,3))

colnames(sindex) <- c("senkId","senkNm","code")


# results

results <- read_xml("data/results.xml")

# results by prefecture
pref_results <- results |>
  xml_find_all("senk")

out_all <- data.frame()
for (i in 1:length(pref_results)) {
  pref <- pref_results[i]

  pref_attr <- pref |>
    xml_attrs() |>
    as.data.frame() |>
    t() |>
    as.data.frame(row.names=F) |>
    select(-vtCntRate)

  colnames(pref_attr)[3] <- "pref_turnout"

  pref_cand <- pref |>
    xml_find_all("koho") |>
    xml_attrs() |>
    as.data.frame() |>
    t() |>
    as.data.frame(row.names=F)

  colnames(pref_cand)[2:4] <- c("pref_votes","pref_voteShare","elected")

  out_pref <- cbind(pref_attr,pref_cand)

  mun_attr <- pref |>
    xml_find_all("plc") |>
    xml_attrs() |>
    as.data.frame() |>
    t() |>
    as.data.frame(row.names=F) |>
    mutate(muncode = str_extract(plcCd,".*(?=00)")) |>
    select(-c(vtCntRate,plcTopKhId))

  colnames(mun_attr)[2:3] <- c("mun_name","mun_turnout")

  out <- data.frame()
  for (i in 1:nrow(mun_attr)) {
    mun_results <- pref |>
      xml_find_all("plc") |>
      magrittr::extract2(i) |>
      xml_find_all("plckh") |>
      xml_attrs() |>
      as.data.frame() |>
      t() |>
      as.data.frame(row.names=F)

    colnames(mun_results)[2:3] <- c("votes","mun_voteShare")

    combined <- cbind(mun_attr[i,],mun_results)
    out <- rbind(out,combined)
  }
  pref_all <- right_join(out_pref,out,by="khId")
  out_all <- rbind(out_all,pref_all)
}

out_all$khId <- as.numeric(out_all$khId)

final <- left_join(out_all,cand_info,by="khId") |>
  select(1:3,5:6,4,14:20,7,11,9:10,12,13)



# Write file --------------------------------------------------------------

write.csv(final, "output/HoC2025_results.csv", row.names = F, fileEncoding = "UTF-8")
