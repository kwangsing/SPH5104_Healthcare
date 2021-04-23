#############################################################################################################
#to clean the dataset from the beginning to ensue the correctness
#############################################################################################################


#-------------------------------------------------------------------------------------------------------------------------------
#to only have teh dataset that has the 48hbefore dataset:

file.choose()

data.toclean=read.csv("E:\\SPH5104 (Analytics for better health)\\group proj\\data-final_shaliniedit.csv", header=T,sep=",")
names(data.toclean)
uniids=data.toclean[!duplicated(data.toclean$subject_id),1] #to store the unique ids
length(uniids) #2480

#to check if the subject contains before values:
havebefore=c(0);Haveb4=data.frame(rep(0,length(uniids)),rep(0,length(uniids)))
dim(Haveb4)#2480 2
head(Haveb4)
for (i in 1:length(uniids)){
  temp=data.toclean[data.toclean$subject_id%in%uniids[i],33] #33rd col is the "hour48"
  Haveb4[i,1]=uniids[i]
  havebefore=c("BEFORE")%in%temp #gives T if the temp has the word before
  Haveb4[i,2]=havebefore
}
#to keep the ids that have only the before data:
subjectswithbefore=Haveb4[Haveb4$rep.0..length.uniids...1==1,1]
length(subjectswithbefore) #2143 with both before and after for the hour48 variable
sum(!duplicated(subjectswithbefore)) #2143

data.toclean.v3=data.toclean[data.toclean$subject_id%in%subjectswithbefore,]

#to store this data, sort it for the charttime and come back
write.csv(data.toclean.v3,"E:\\SPH5104 (Analytics for better health)\\group proj\\to save teh final daatset\\data.toclean.v3.csv")

file.choose()
data.toclean.v3.ordered=read.csv("E:\\SPH5104 (Analytics for better health)\\group proj\\to save teh final daatset\\data.toclean.v3.csv", header=T,sep=",")

subjectid.onlyb4=data.toclean.v3.ordered[!duplicated(data.toclean.v3.ordered$subject_id),2]#2143;length(subjectid.onlyb4) to store the subject ids
names(data.toclean.v3.ordered)
numofrows.3.b4=data.frame(rep(0,length(subjectid.onlyb4)),rep(0,length(subjectid.onlyb4)), rep(0,length(subjectid.onlyb4)), rep(0,length(subjectid.onlyb4)))

for(i in 1:length(subjectid.onlyb4)){
  numofrows.3.b4[i,1] = subjectid.onlyb4[i] #to store the subject id
  #print(i)
  numofrows.3.b4[i,2] =as.numeric(table(data.toclean.v3.ordered$subject_id)[i]) #second column contains the number or rows of data
  store=rep(0,numofrows.3.b4[i,2]); store2=rep(0,numofrows.3.b4[i,2])
  store=data.toclean.v3.ordered[data.toclean.v3.ordered$subject_id%in%subjectid.onlyb4[i],39] #to get the "pao2fio2"
  store=as.numeric(store)
  numofrows.3.b4[i,3]=last(store[!is.na(store)]) #to get the first non null valuez[!is.na(z)][1]
  store2=data.toclean.v3.ordered[data.toclean.v3.ordered$subject_id%in%subjectid.onlyb4[i],38] #to get the "spo2" value
  store2=as.numeric(store2)
  numofrows.3.b4[i,4]=last(store2[!is.na(store2)]) #to get the spo2 value
}
#just combine teh data with the before data values
final0nlybefore.2ndpparil=cbind(data.toclean.v3.ordered[!duplicated(data.toclean.v3.ordered$subject_id),],numofrows.3.b4)


#-------------------------------------------------------------------------------------------------
#now to see if the data meets the eligiility criterias
#to change the admission age for those with the value > 300
max(final0nlybefore.2ndpparil$admission_age) #305.3448; min(final0nlybefore.2ndpparil$admission_age)#17.19198
final0nlybefore.2ndpparil$admission_age.edited=ifelse(final0nlybefore.2ndpparil$admission_age>300,91,final0nlybefore.2ndpparil$admission_age)
max(final0nlybefore.2ndpparil$admission_age.edited)#91
final0nlybefore.2ndpparil.abv18=final0nlybefore.2ndpparil[final0nlybefore.2ndpparil$admission_age.edited>=18,]
min(final0nlybefore.2ndpparil.abv18$admission_age.edited)#18.13912

#need to exclude those with HFOV
max(final0nlybefore.2ndpparil.abv18$hfov) #1 so there are people with HFOV
final0nlybefore.2ndpparil.abv18.noHFOV=final0nlybefore.2ndpparil.abv18[final0nlybefore.2ndpparil.abv18$hfov==0,]
length(final0nlybefore.2ndpparil.abv18.noHFOV[,1]) #2136
summary(final0nlybefore.2ndpparil.abv18.noHFOV$hfov)

#to exlude those who have stayed less than 24h in ICU: los_icu is indicates the number of days in ICU
class(final0nlybefore.2ndpparil.abv18.noHFOV$los_icu) #numeric
final0nlybefore.2ndpparil.abv18.noHFOV.staymore24=final0nlybefore.2ndpparil.abv18.noHFOV[final0nlybefore.2ndpparil.abv18.noHFOV$los_icu>=1,]
summary(final0nlybefore.2ndpparil.abv18.noHFOV.staymore24$los_icu) #1.005 is the minimum
length(final0nlybefore.2ndpparil.abv18.noHFOV.staymore24$los_icu) #2018

#to exclude subjects with either ecmo or nitric oxide:
class(final0nlybefore.2ndpparil.abv18.noHFOV.staymore24$ecmo) #int
class(final0nlybefore.2ndpparil.abv18.noHFOV.staymore24$nitric_oxide)#int
summary(final0nlybefore.2ndpparil.abv18.noHFOV.staymore24$ecmo)#max is 1
summary(final0nlybefore.2ndpparil.abv18.noHFOV.staymore24$nitric_oxide)#max is 1

#to add in another col tat indicates 1 if either one of the 2 is present
final0nlybefore.2ndpparil.abv18.noHFOV.staymore24$ecmoorNOpresent=rep(0,length(final0nlybefore.2ndpparil.abv18.noHFOV.staymore24[,1]))

for(i in 1:length(final0nlybefore.2ndpparil.abv18.noHFOV.staymore24[,1])){
  if(final0nlybefore.2ndpparil.abv18.noHFOV.staymore24$ecmo[i]==1) {
    final0nlybefore.2ndpparil.abv18.noHFOV.staymore24$ecmoorNOpresent[i]=1}
  if(final0nlybefore.2ndpparil.abv18.noHFOV.staymore24$nitric_oxide[i]==1){
    final0nlybefore.2ndpparil.abv18.noHFOV.staymore24$ecmoorNOpresent[i]=1
  }
}
meetcriteria.v2=final0nlybefore.2ndpparil.abv18.noHFOV.staymore24[final0nlybefore.2ndpparil.abv18.noHFOV.staymore24$ecmoorNOpresent!=1,]
length(meetcriteria.v2[,1]) #2009
length(final0nlybefore.2ndpparil.abv18.noHFOV.staymore24[,1])
sum(final0nlybefore.2ndpparil.abv18.noHFOV.staymore24$ecmo)#1
sum(final0nlybefore.2ndpparil.abv18.noHFOV.staymore24$nitric_oxide)#8

#to save this data
write.csv(meetcriteria.v2,"E:\\SPH5104 (Analytics for better health)\\group proj\\to save teh final daatset\\meetcriteria.v2.csv")

#====================================================================================================================================================================
#to have no NA in the columns we are interested in.

#first is the data used for primary outcome:
file.choose()
meetcriteria.v2=read.csv("E:\\SPH5104 (Analytics for better health)\\group proj\\to save teh final daatset\\meetcriteria.v2.csv", header=T,sep=",")
names(meetcriteria.v2)
length(meetcriteria.v2[,1])#2009
sum(!duplicated(meetcriteria.v2$icustay_id))
#just need to relabel certain variables before getting the final complete dataset
class(meetcriteria.v2[,11])# "admission_age" is numeric
class(meetcriteria.v2[,13])# "mortality_90day" is integer
class(meetcriteria.v2[,24]) #weight is a character because there are NULL values
class(meetcriteria.v2[,33]) #"sapsii" is an integer
class(meetcriteria.v2[,34]) #sofa is an integer
class(meetcriteria.v2[,41]) #"prone_position" is a character SHOULD USE THE VARIABLE: PRONE_POSITION RELABELLED
class(meetcriteria.v2[,18]) #numeric
class(meetcriteria.v2[,45])#numeric for the 48hbe4pao2fio2 ratio
class(meetcriteria.v2[,46])#integer

meetcriteria.v2$weight=as.numeric(meetcriteria.v2$weight)
#meetcriteria.v2.completecase=meetcriteria.v2[!is.na(meetcriteria.v2[11,13,18,24]),]
#18,24,33,34,39,40,49,50

meetcriteria.v2.completecase=na.omit(meetcriteria.v2,c(meetcriteria.v2[,11],meetcriteria.v2[,13],meetcriteria.v2[,18],meetcriteria.v2[,24],meetcriteria.v2[,33],meetcriteria.v2[,34],meetcriteria.v2[,45],meetcriteria.v2[,46],meetcriteria.v2[,49],meetcriteria.v2[,50]))
length(meetcriteria.v2.completecase[,1]) #1689  complete dataset

write.csv(meetcriteria.v2.completecase,"E:\\SPH5104 (Analytics for better health)\\group proj\\to save teh final daatset\\meetcriteria.v2.completecase.csv")

table(meetcriteria.v2.completecase$TREAT1ELSE0)
table(meetcriteria.v2$TREAT1ELSE0)
table(meetcriteria.v2.completecase$mortality_90day)
table(meetcriteria.v2$mortality_90day)

#just so to change the age for those above 300 to 91.4, edited on 4th april:
file.choose()
meetcriteria.v2.completecase.4thapril=read.csv("E:\\SPH5104 (Analytics for better health)\\group proj\\to save teh final daatset\\meetcriteria.v2.completecase.csv", header=T, sep=",")
names(meetcriteria.v2.completecase.4thapril)
meetcriteria.v2.completecase.4thapril$admission_age.edited=ifelse(meetcriteria.v2.completecase.4thapril$admission_age>300,91.4,meetcriteria.v2.completecase.4thapril$admission_age)
#max(meetcriteria.v2.completecase.4thapril$admission_age.edited)
write.csv(meetcriteria.v2.completecase.4thapril,"E:\\SPH5104 (Analytics for better health)\\group proj\\to save teh final daatset\\meetcriteria.v2.completecase.4thapril.csv")
length(meetcriteria.v2.completecase.4thapril[,1])#1689
#sum(is.na(as.numeric(meetcriteria.v2.completecase.4thapril$vent_duration))) #87




###+++++++++++++++++++++++++++++++++++
#to clean the data further and remove the null values in the vent_duration
file.choose()
meetcriteria.v2.toclean=read.csv("E:\\SPH5104 (Analytics for better health)\\group proj\\to save teh final daatset\\meetcriteria.v2.csv", header=T,sep=",")
names(meetcriteria.v2.toclean)
class(meetcriteria.v2.toclean$vent_duration)
meetcriteria.v2.toclean$vent_duration=as.numeric(meetcriteria.v2.toclean$vent_duration)
meetcriteria.v2.removenullventduration=na.omit(meetcriteria.v2.toclean,c(meetcriteria.v2.toclean[,32]))
length(meetcriteria.v2.toclean[,1])#2009
length(meetcriteria.v2.removenullventduration[,1]) #1616

#need to change the age to 91.4 for those who are above 300
meetcriteria.v2.removenullventduration$admission_age.edited=ifelse(meetcriteria.v2.removenullventduration$admission_age>300,91.4,meetcriteria.v2.removenullventduration$admission_age)
max(meetcriteria.v2.removenullventduration$admission_age.edited)#to check that the age has been edited
summary(meetcriteria.v2.removenullventduration$los_hospital)


file.choose()
meetcriteria.v3.completecase=na.omit(meetcriteria.v2.toclean,c(meetcriteria.v2.toclean[,11],meetcriteria.v2.toclean[,13],meetcriteria.v2.toclean[,18],meetcriteria.v2.toclean[,24],meetcriteria.v2.toclean[,33],meetcriteria.v2.toclean[,34],meetcriteria.v2.toclean[,45],meetcriteria.v2.toclean[,49],meetcriteria.v2.toclean[,50]))
length(meetcriteria.v3.completecase[,1])#1616
meetcriteria.v3.completecase$vent_duration=as.numeric(meetcriteria.v3.completecase$vent_duration)
meetcriteria.v3.removenullventduration=na.omit(meetcriteria.v3.completecase,c(meetcriteria.v3.completecase[,32]))
length(meetcriteria.v3.removenullventduration[,1])#1616

#TO GET THE COMPLETE CASE WHEN VENT DURATION WAS IGNORED AND THE 48HBSPO2 WAS IGNORED AS WELL:
meetcriteria.v3.completecase=na.omit(meetcriteria.v2,c(meetcriteria.v2[,11],meetcriteria.v2[,13],meetcriteria.v2[,18],meetcriteria.v2[,24],meetcriteria.v2[,33],meetcriteria.v2[,34],meetcriteria.v2[,45],meetcriteria.v2[,49],meetcriteria.v2[,50]))
length(meetcriteria.v3.completecase[,1])#1689
class(meetcriteria.v3.completecase$hours48before.pao2fio2)#numeric

meetcriteria.v2.completecase[!(meetcriteria.v2.completecase[,1]%in%meetcriteria.v3.check[,1]),"subject_id"]


#to get the complete case without the spo2 included but do not use the vent duration to get the complete dataset.
meetcriteria.v2=read.csv("E:\\SPH5104 (Analytics for better health)\\group proj\\to save teh final daatset\\meetcriteria.v2.csv", header=T,sep=",")
meetcriteria.v3=meetcriteria.v2
meetcriteria.v3$weight=as.numeric(meetcriteria.v3$weight)
meetcriteria.v3$los_hospital=as.numeric(meetcriteria.v3$los_hospital)
meetcriteria.v3$los_icu=as.numeric(meetcriteria.v3$los_icu)
meetcriteria.v3$vent_duration=as.numeric(meetcriteria.v3$vent_duration)
meetcriteria.v3$admission_age.edited=ifelse(meetcriteria.v3$admission_age>300,91.4,meetcriteria.v3$admission_age)
meetcriteria.v3.complete=na.omit(meetcriteria.v3,cols=c("admission_age.edited","mortality_90day","los_icu","weight","sapsii","sofa","hours48before.pao2fio2","prone.position.relabelled","TREAT1ELSE0","first_careunit","last_careunit","los_hospital"))
length(meetcriteria.v3.complete[,1]) #1602
#meetcriteria.v2$vent_duration
meetcriteria.v3.check=na.omit(meetcriteria.v3,cols=c("admission_age","mortality_90day","los_icu","weight","sapsii","sofa","hours48before.pao2fio2","prone.position.relabelled","TREAT1ELSE0","hours48before.spo2" ))
length(meetcriteria.v3.check[,1])
length(meetcriteria.v3[,1])

###to get the subset of dataset without the missing values but excluding the "hours48before.spo2"
meetcriteria.v2=read.csv("E:\\SPH5104 (Analytics for better health)\\group proj\\to save teh final daatset\\meetcriteria.v2.csv", header=T,sep=",")
#to change the age:
meetcriteria.v2$admission_age.edited=ifelse(meetcriteria.v2$admission_age>300,91.4,meetcriteria.v2$admission_age)
max(meetcriteria.v2$admission_age.edited)
subset=meetcriteria.v2[,c("subject_id","admission_age.edited","mortality_90day","los_icu","weight","sapsii","sofa","hours48before.pao2fio2","prone.position.relabelled","TREAT1ELSE0","first_careunit","last_careunit","los_hospital","vent_duration")]
names(subset)
#class(subset$vent_duration)
#table(subset$first_careunit)
#class(subset$weight)
#class(subset$los_hospital)
#class(subset$last_careunit) #character
subset$weight=as.numeric(subset$weight)
subset$los_hospital=as.numeric(subset$los_hospital)
subset$los_icu=as.numeric(subset$los_icu)
subset$vent_duration=as.numeric(subset$vent_duration)
subset.cleaned=na.omit(subset)
#length(subset.cleaned[,1])#1618
#table(meetcriteria.v2$gender)
#to match with the rest of the dataset this dataset was cleaned with the inclusion of the hospital los and the vent duration:
newsubset.cleaned=meetcriteria.v2[(meetcriteria.v2$subject_id)%in%(subset.cleaned$subject_id),]
#length(newsubset.cleaned[,1]) #1618
#names(newsubset.cleaned)
#to store this data:
write.csv(newsubset.cleaned,"E:\\SPH5104 (Analytics for better health)\\group proj\\to save teh final daatset\\newsubset.cleaned.csv")

