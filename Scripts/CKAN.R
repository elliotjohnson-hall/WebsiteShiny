library(jsonlite)
library(glue)
library(ckanr)
library(tidyverse)

BaseURL <-  "https://www.opendata.nhs.scot/"

ResourceIDs <- package_show(id = "84393984-14e9-4b0d-a797-b288db64d088",
               url = BaseURL,
               as = "table")$resources %>% select(id)

NumberOfRecordsFound <- nrow(ResourceIDs)
NumberOfRecordsRetrieved <- length(unique(CompleteDataset$RecordNumber))

if (NumberOfRecordsFound > NumberOfRecordsRetrieved) {
  ChoiceToUpdate <-
    menu(
      title = glue(
        "{NumberOfRecordsFound - NumberOfRecordsRetrieved} new records found. Would you like to update the data?"
      ),
      choices = c("Yes", "No")
    )

  if (ChoiceToUpdate == 1L) {
    message("Updating data. This may take some time.")
    for (Record in NumberOfRecordsRetrieved + 1:NumberOfRecordsFound) {
      message(glue("Retrieving record {Record} of {NumberOfRecords}."))
      ResourceID <- ResourceIDs[Record,]
      SQL <-
        glue(
          'SELECT * from "{ResourceID}" WHERE ',
          '"BNFItemCode"',
          " LIKE '07030%' OR ",
          '"BNFItemCode"',
          " LIKE '21040%'"
        )
      TempResult <- ds_search_sql(SQL, url = BaseURL, as = "json")
      DataList <- fromJSON(TempResult)
      assign(glue("DF{Record}"), DataList$result$records)
      message(glue("{((NumberOfRecordsFound - NumberOfRecordsRetrieved) / Record)
                   * 100}% complete."))
    }

    DataFrameList <- mget(ls(pattern = "DF"))
    # CompleteDataset <- bind_rows(DataFrameList)
    CompleteDataset <- bind_rows(list(CompleteDataset, DataFrameList))
    # write_rds(CompleteDataset, "Data.RDS")
    remove(list = ls(pattern = "DF"))
    CompleteDataset <- CompleteDataset %>%
      mutate(HealthBoard = case_when(is.na(HBT) ~ HBT2014,!is.na(HBT) ~ HBT)) %>%
      select(-c(`_id`, `_full_text`, HBT2014, HBT))

  }
  else {
    message("You got it Chief, doing nada.")
  }
}
