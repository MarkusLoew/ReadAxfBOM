#' Import a weather station observation axf-file downloaded from a Australian Bureau of Meteorology station
#' 
#' @param data Filename of the axf file.
#' @return Data frame with the observations in file. See http://www.bom.gov.au/weather-services/about/IDY03000.doc for details
#' @examples 
#' \dontrun{
#' observations <- ReadAxfBOM(filename.axf)
#' }


ReadAxfBOM <- function(data) {
        # import whole file for analysis
        raw <- readLines(data)

        # individual sections of the file start with "[someword]"
        # and end with "[$]"
        # sections are "[notice]", "[header]", "[data]"

        # find rows that start with "["
        header.starts <- grepl("^\\[", raw)
        header.starts <- which(header.starts) # numeric

        # find header names
        # header.names <- raw[header.starts]

        # the notice, header, and data blocks, not all used currently
        # notice.location <- header.starts[1:2]
        # header.location <- header.starts[3:4]
        data.location   <- header.starts[5:6]

        # not interested in the notice or header blocks for now

        # calculate length of the data block
        data.rows <- data.location[2] - data.location[1] - 2

        # actual import of the data
        the.data <- utils::read.csv(data,
                                    skip = data.location[1],
                                    nrows = data.rows)

        # get rid of th e".[80]" in some of the names
        names(the.data) <- gsub("\\.80\\.", "", names(the.data))

        # the parameter "local_date_time" has local time.
        # "local_date_time_full" seems to be what we are after (24hour clock)

        # workaround for midnight
        # midnight is converted to a different number format
        # than other times of the day during import
        the.data$local_date_time_full <- sprintf("%.0f",
                                                 the.data$local_date_time_full)

        # convert to POSIX time
        the.data$Timestamp <- as.POSIXct(the.data$local_date_time_full,
                                         format = "%Y%m%d%H%M%S")
        # get rid of variable "sort_order"
        # as it will prevent to identify duplicate samples
        the.data$sort_order <- NULL

        # re-order data frame, to have time in front
        time.var <- which(names(the.data) == "Timestamp")
        the.data <- the.data[, c(time.var, 1:length(names(the.data)) - 1)]

        # identify special weather events which are
        # outside of the 30min measurement frequency
        # create complete time-series from start to end of data in the the.file
        end.time   <- the.data$Timestamp[1]
        start.time <- the.data$Timestamp[length(the.data$Timestamp)]

        # create complete time series based on 30 min data
        comp.time <- seq(from = start.time, to = end.time, by = "30 min")

        # match timezone information with the.data
        # self-created time series has no timezone information
        # but it seems tz is needed for the comparison later
        # extract tz information from the.data
        data.tz <- attr(the.data$Timestamp, "tzone")
        attr(comp.time, "tzone") <- data.tz

        # compare complete series with the actual series
        regular.times <- the.data$Timestamp %in% comp.time
        irregular.times <- which(regular.times == FALSE)

        # add an indicator to mark irregular events
        the.data$extreme_event <- FALSE
        the.data$extreme_event[irregular.times] <- TRUE

        return(the.data)
}
