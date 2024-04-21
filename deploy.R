library(rsconnect)

error_on_missing_name <- function(name) {
    var <- Sys.getenv(name, unset=NA)
    if(is.na(var)) {
        stop(paste0("cannot find ", name, " !"), call.=FALSE)
    }
    gsub("\"", "", var)
}

#authenticate
setAccountInfo(
    name=error_on_missing_name("SHINYAPPS_ACCOUNT"),
    token=error_on_missing_name("SHINYAPPS_TOKEN"),
    secret=error_on_missing_name("SHINYAPPS_SECRET")
)

#deploy app
deployApp(appFiles = c("ui.R", "server.R"), appName="consultingproject", forceUpdate=TRUE)