#helper function to unzip data
unzipfunction <- function(f){
  print(paste("attempting to extract data from: ", f))
  tryCatch(unzip(f), 
           warning = function(w) {print(w);}, 
           error = function(e) {print(e);}
  )
}


dataURL="https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
zipName <- "household_power_consumption.zip"
dataFileName <- "household_power_consumption.txt";

if(!file.exists(zipName)) download.file(dataURL, destfile = zipName)
if(!file.exists(dataFileName)) unzipfunction(zipName)


library(sqldf)

#read data, subsetting by date
hpc <- read.csv.sql(file=dataFileName, 
                    sql = "select * from file where Date = '1/2/2007' or Date = '2/2/2007'", 
                    header = TRUE, 
                    sep = ";",
                    colClasses=c("character", "character", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric"))

#read.csv.sql does not provide automatic substitution for NA values
hpc[hpc=="?"] <- NA

#convert Date & Time columns from characters to dates
hpc$DateTime <- strptime(paste(hpc$Date, hpc$Time), format="%d/%m/%Y %H:%M:%S")

#prepare to save graph as .png file
png("plot4.png")


par(mfrow=c(2,2), mar=c(4,4,2,1));


#create graph (1,1)
plot(hpc$DateTime, hpc$Global_active_power, type="l", xlab="", ylab="Global Active Power")


#create graph (1,2)
plot(hpc$DateTime, hpc$Voltage, type="l", xlab="datetime", ylab="Voltage")

#create graph (2,1)
plotColors <- c("black", "red", "blue");
with(hpc,{
  plot(DateTime, Sub_metering_1, type="l", col=plotColors[1], xlab="", ylab="Energy sub metering");
  lines(DateTime, Sub_metering_2, type="l", col=plotColors[2]);
  lines(DateTime, Sub_metering_3, type="l", col=plotColors[3]);
})
legend("topright", pch="", lwd=2, col=plotColors, bty = "n", legend=c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"));


#create graph (2,2)
with(hpc, plot(DateTime, Global_reactive_power, type="l", xlab="datetime"))



#close file connection
dev.off()


#clean-up!
rm(list=ls())





