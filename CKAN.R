library(jsonlite)
library(glue)
library(ckanr)
library(tidyverse)

BaseURL <-  "https://www.opendata.nhs.scot/"


ResourceIDs <- package_show(id = "84393984-14e9-4b0d-a797-b288db64d088",
               url = BaseURL,
               as = "table")$resources %>%
  select(id)

for (Record in 1:nrow(ResourceIDs)) {
  ResourceID <- ResourceIDs[Record, ]
  SQL <-
    glue('SELECT * from "{ResourceID}" WHERE ',
      '"BNFItemCode"',
      " LIKE '07030%' OR ",
      '"BNFItemCode"',
      " LIKE '21040%'")
  TempResult <- ds_search_sql(SQL, url = BaseURL, as = "json")
  DataList <- fromJSON(TempResult)
  assign(glue("Data{Record}"), DataList$result$records)
}

DataFrameList <- mget(ls(pattern = "Data"))
CompleteDataset <- bind_rows(DataFrameList)
remove(list = ls(pattern = "Data"))

CompleteDataset <- CompleteDataset %>%
  mutate(HealthBoard = case_when(is.na(HBT) ~ HBT2014,!is.na(HBT) ~ HBT)) %>%
  select(-c(help, success, result, `_id`, `_full_text`, HBT2014, HBT))
