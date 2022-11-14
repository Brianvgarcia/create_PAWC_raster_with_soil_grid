#https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0169748
#This script will create a raster with the plant available water content from 0 to 200 cm soil depth, taking as base the raster information reported from soild grids.
#https://data.isric.org/geonetwork/srv/eng/catalog.search#/metadata/e33e75c0-d9ab-46b5-a915-cb344345099c
###
library(raster)
library(sp)
library(rgeos)
library(rgdal)

path<-"F:/your_directory"
rasters<-list.files("F:/your_raster_files",pattern=".tif$",all.files = TRUE,full.names = TRUE)
shp_cuenca<-readOGR("F:/your_study_zone.shp")
plot(shp_cuenca)
rain_raster<-stack(rasters)
plot(rain_raster[[1]])

#reproject raster
transformado <- spTransform(shp_cuenca,crs(rain_raster))
# buffer_shp <- gBuffer(shp_cuenca, width = 1000, quadsegs = 10)
# plot(buffer_shp)
# plot(shp_cuenca,add=TRUE)

corte<-raster::crop(rain_raster,transformado)
plot(corte[[1]])
plot(transformado,add=TRUE)
corte_cuenca<-raster::mask(corte,transformado)
plot(corte_cuenca)

corte_cuenca$WWP_M_sl1_250m_ll


x<-(1/(200-0))*(1/2)*(((5-0)*(corte_cuenca$WWP_M_sl1_250m_ll + corte_cuenca$WWP_M_sl2_250m_ll)) + 
                     ((15-5)*(corte_cuenca$WWP_M_sl2_250m_ll + corte_cuenca$WWP_M_sl3_250m_ll)) + 
                     ((30-15)*(corte_cuenca$WWP_M_sl3_250m_ll + corte_cuenca$WWP_M_sl4_250m_ll)) + 
                     ((60-30)*(corte_cuenca$WWP_M_sl4_250m_ll + corte_cuenca$WWP_M_sl5_250m_ll)) + 
                     ((100-60)*(corte_cuenca$WWP_M_sl5_250m_ll + corte_cuenca$WWP_M_sl6_250m_ll)) + 
                     ((200-100)*(corte_cuenca$WWP_M_sl6_250m_ll +corte_cuenca$WWP_M_sl7_250m_ll)))

plot(x)

#par(mfrow=c(1,1))
raster_PAWC<-x/100 #Value standarization from 0 to 1.
plot(raster)
writeRaster(raster_PAWC, filename=file.path(path, "PAWC.tif"), format="GTiff", overwrite=TRUE)

