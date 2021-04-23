#############################################################################################################
#Analysis using IPW.
#dataset used is the one cleaned involving the vent_duration
#this is based on the final cleaned dataset

#############################################################################################################

#package to use:
library(ipw)
library(survey)
library(tableone)
library(car)
library(cobalt)
library(sm)
library(MatchIt)
library(ggplot2)
#to get the data
file.choose()
#to read in the data:
data.final=read.csv("E:\\SPH5104 (Analytics for better health)\\group proj\\to save teh final daatset\\before_matching_data_final.csv", header=T, sep=",")
#names(data.final)
#length(data.final[,1])#1110
#table(data.final$mortality_90day)#310 people die
#table(data.final$TREAT1ELSE0,data.final$mortality_90day)


#to create certain variables to be saved as factors:
data.final$gender=as.factor(data.final$gender)
data.final$mortality_90day=as.factor(data.final$mortality_90day)
data.final$first_careunit=as.factor(data.final$first_careunit)
data.final$prone.position.relabelled=as.factor(data.final$prone.position.relabelled)
data.final$TREAT1ELSE0=as.factor(data.final$TREAT1ELSE0)

#just to observe the distribution of the various variables also to assess normality:
#plots for the age first
p<-ggplot(data.final, aes(x=TREAT1ELSE0, y=admission_age.edited, fill=TREAT1ELSE0)) +
  geom_boxplot()
p

#to get the plot for weight
weightvar<-ggplot(data.final, aes(x=TREAT1ELSE0, y=weight, fill=TREAT1ELSE0)) +
  geom_boxplot()
weightvar
qqPlot(data.final[data.final$TREAT1ELSE0==1,"weight"], main="females weight")
qqPlot(data.final[data.final$TREAT1ELSE0==0,"weight"], main="males weight")

#to get the plot forr sofa:
sofavar<-ggplot(data.final, aes(x=TREAT1ELSE0, y=sofa, fill=TREAT1ELSE0)) +
  geom_boxplot()
sofavar

#to get the plot for sapsii:
sapsiivar<-ggplot(data.final, aes(x=TREAT1ELSE0, y=sapsii, fill=TREAT1ELSE0)) +
  geom_boxplot()
sapsiivar

#to get the plot for pfratio:
pfratiovar<-ggplot(data.final, aes(x=TREAT1ELSE0, y=hours48before.pao2fio2, fill=TREAT1ELSE0)) +
  geom_boxplot()
pfratiovar

#to get the plot for los_icu
losicuvar<-ggplot(data.final, aes(x=TREAT1ELSE0, y=los_icu, fill=TREAT1ELSE0)) +
  geom_boxplot()
losicuvar

#to get the plpot fot los_hospital
loshospitalvar<-ggplot(data.final, aes(x=TREAT1ELSE0, y=los_hospital, fill=TREAT1ELSE0)) +
  geom_boxplot()
loshospitalvar


#to get the baseline table:
Xvariables = c("gender","first_careunit","prone.position.relabelled","admission_age.edited", "hours48before.pao2fio2", "weight", "sapsii", "sofa", 
               "prone.position.relabelled","los_icu","los_hospital")
baselinetable<- CreateTableOne(vars = Xvariables, strata = "TREAT1ELSE0", 
                               data =data.final, test = T)
print(baselinetable,nonnormal=c("admission_age.edited", "hours48before.pao2fio2", "weight", "sapsii", "sofa", "los_icu","los_hospital"),exact=c("gender","first_careunit","prone.position.relabelled"), smd = TRUE)
print(baselinetable, smd=T) #to get the mean and sd values

#-----------------------------------------------------------------------------------------
#to do logistic regression on the original cohort without any other variables:
logit.mortality.basemodel <- glm(mortality_90day ~TREAT1ELSE0,
                                  family = binomial(), data = data.final)
summary(logit.mortality.basemodel)
confint(logit.mortality.basemodel)
#to get the odds ratio and confidence intervals:
exp(cbind(OR = coef(logit.mortality.basemodel), confint(logit.mortality.basemodel)))
#to do the usual logistic regression with covariates:
logit.mortality.everything <- glm(mortality_90day ~TREAT1ELSE0+los_icu+los_hospital+weight+admission_age.edited+hours48before.spo2+sofa+sapsii+prone.position.relabelled+first_careunit,
                                  family = binomial(), data = data.final)
summary(logit.mortality.everything)
confint(logit.mortality.everything)
exp(cbind(OR = coef(logit.mortality.everything), confint(logit.mortality.everything)))
#to rerun the model without the los_icu but include the los_hospital:
logit.mortality.everything.nolosicu <- glm(mortality_90day ~TREAT1ELSE0+los_hospital+weight+admission_age.edited+hours48before.spo2+sofa+sapsii+prone.position.relabelled+first_careunit,
                                  family = binomial(), data = data.final)
summary(logit.mortality.everything.nolosicu)
confint(logit.mortality.everything.nolosicu)
exp(cbind(OR = coef(logit.mortality.everything.nolosicu), confint(logit.mortality.everything.nolosicu)))
#--------------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------------
#to get the weights using the logistic regression method
logit.ps <- glm(TREAT1ELSE0 ~admission_age.edited+hours48before.pao2fio2+weight+sofa+sapsii+prone.position.relabelled+first_careunit+gender,
                family = binomial(), data = data.final)
summary(logit.ps)
exp(cbind(OR = coef(logit.ps), confint(logit.ps)))
#to get the propensity score
ps.logitmodel <- predict(logit.ps, type = "response")
data.final$ps.logitmodel=ps.logitmodel
#-----------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------
#to get the density plots of the propensity scores obtained. This is before matching.
sm.density.compare(data.final$ps.logitmodel,data.final$TREAT1ELSE0, data=data.final)#to get the overlap. 
plot(density(data.final[data.final$TREAT1ELSE0==1,]$ps.logitmodel))
plot(density(data.final[data.final$TREAT1ELSE0==0,]$ps.logitmodel))
#------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------
#to create the IPW weights and the baseline table:
weight_create = ifelse(data.final$TREAT1ELSE0 == 1, 1/(data.final$ps.logitmodel), 1/(1-data.final$ps.logitmodel))
summary(weight_create)#this summary matches: summary(weightmodel.redo $ipw.weights)
#to create weighted data:
weighteddata <- svydesign(~1, data = data.final, weights = ~ weight_create)
weightedtable <- svyCreateTableOne(vars = Xvariables, strata = "TREAT1ELSE0", 
                                   data = weighteddata, test = T)
print(weightedtable,nonnormal=c("admission_age.edited", "hours48before.pao2fio2", "weight", "sapsii", "sofa","los_icu","los_hospital"),exact=c("gender","first_careunit","prone.position.relabelled"), smd = TRUE)
print(weightedtable, smd=T)
#-------------------------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------------------
#to conduct logistic regression using the weighted data:
model1.base <- (svyglm(mortality_90day ~ TREAT1ELSE0, design = svydesign(~ 1, weights = ~ weight_create,
                                                                    data = data.final), family=quasibinomial()))
#quasibinomial was used for the family as the family=binomial(link="logit")
summary(model1.base)
coef(model1.base)
confint(model1.base)
exp(cbind(OR = coef(model1.base), confint(model1.base)))


#to add the los to the ipw weighted dataset
model1.losadded <- (svyglm(mortality_90day ~ TREAT1ELSE0+los_icu+los_hospital, design = svydesign(~ 1, weights = ~ weight_create,
                                                                                         data = data.final), family=quasibinomial()))
summary(model1.losadded)
coef(model1.losadded)
confint(model1.losadded)
exp(cbind(OR = coef(model1.losadded), confint(model1.losadded)))

#without the los_icu (Some additional observations):
model1.nolosicu <- (svyglm(mortality_90day ~ TREAT1ELSE0+los_hospital, design = svydesign(~ 1, weights = ~ weight_create,
                                                                                                  data = data.final), family=quasibinomial()))
summary(model1.nolosicu)
coef(model1.nolosicu)
confint(model1.nolosicu)
exp(cbind(OR = coef(model1.nolosicu), confint(model1.nolosicu)))

#---------------------------------------------------------------------------------------------------


#####===============================================================================================
#to try the matching method to get the propensity score
matched.1 <- matchit(TREAT1ELSE0 ~ admission_age.edited+hours48before.pao2fio2+weight+sofa+sapsii+prone.position.relabelled+first_careunit+gender,
                     method = "nearest", data =data.final)
dta_matched1 <- match.data(matched.1 )
#dim(dta_matched1)#262 57
plot(matched.1 )
summary(matched.1 )
#to get the density plots of the matched cohorts.
sm.density.compare(dta_matched1$distance,dta_matched1$TREAT1ELSE0, data=dta_matched1)#to get the overlap. 
plot(density(dta_matched1[dta_matched1$TREAT1ELSE0==1,]$distance))
plot(density(dta_matched1[dta_matched1$TREAT1ELSE0==0,]$distance))
#####================================================================================================

#####================================================================================================
#to get the matched table 
Xvariables = c("gender","first_careunit","prone.position.relabelled","admission_age.edited", "hours48before.pao2fio2", "weight", "sapsii", "sofa", 
               "prone.position.relabelled", "los_icu","los_hospital")
baselinetable.matched<- CreateTableOne(vars = Xvariables, strata = "TREAT1ELSE0", 
                                       data =dta_matched1, test = T)
print(baselinetable.matched,nonnormal=c("admission_age.edited", "hours48before.pao2fio2", "weight", "sapsii", "sofa","los_icu","los_hospital"),exact=c("gender","first_careunit","prone.position.relabelled"), smd = TRUE)
print(baselinetable.matched, smd=T) #to get the mean and sd data
#####=================================================================================================

#####=================================================================================================
#to ensure the nominal variables are included as factors
dta_matched1$gender=as.factor(dta_matched1$gender)
#str(datatouse$gender)
dta_matched1$mortality_90day=as.factor(dta_matched1$mortality_90day)
dta_matched1$first_careunit=as.factor(dta_matched1$first_careunit)
dta_matched1$prone.position.relabelled=as.factor(dta_matched1$prone.position.relabelled)
dta_matched1$TREAT1ELSE0=as.factor(dta_matched1$TREAT1ELSE0)

#####to do logistic regression on the propensity matched dataset
logit.mortality.matched1 <- glm(mortality_90day ~TREAT1ELSE0,
                                family = binomial(), data = dta_matched1)
summary(logit.mortality.matched1)
coef(logit.mortality.matched1)
confint(logit.mortality.matched1)
exp(cbind(OR = coef(logit.mortality.matched1), confint(logit.mortality.matched1)))



#on the matched cohort with the los_icu and los_hospital added:
logit.mortality.matched3 <- glm(mortality_90day ~TREAT1ELSE0+los_icu+los_hospital,
                                family = binomial(), data = dta_matched1)
summary(logit.mortality.matched3 )
coef(logit.mortality.matched3 )
confint(logit.mortality.matched3 )
exp(cbind(OR = coef(logit.mortality.matched3 ), confint(logit.mortality.matched3)))
#####===================================================================================================


###############################################################################################################
#to do the subgroup analysis using the new data that was created using the IPW but for age: above 60 and below 60

#to try doing the logistic regression using the svyglm but using the subpop method. 
#this is the original codes used:
#to conduct logistic regression using the weighted data:
#model1.base <- (svyglm(mortality_90day ~ TREAT1ELSE0, design = svydesign(~ 1, weights = ~ weight_create,
#                                                                         data = data.final), family=quasibinomial()))

model.design=svydesign(~ 1, weights = ~ weight_create,data = data.final)

#to get the logistic regression for those above 60 years:
subet1=subset(model.design, admission_age.edited>=60)
logit.subsetolder <- (svyglm(mortality_90day~TREAT1ELSE0, family=quasibinomial(), design=subet1))
summary(logit.subsetolder)
coef(logit.subsetolder)
confint(logit.subsetolder)
exp(cbind(OR = coef(logit.subsetolder), confint(logit.subsetolder)))
#repeat with the los added in:
logit.subsetoldelos <- (svyglm(mortality_90day~TREAT1ELSE0+los_icu+los_hospital, family=quasibinomial(), design=subet1))
summary(logit.subsetoldelos )
coef(logit.subsetoldelos )
confint(logit.subsetoldelos )
exp(cbind(OR = coef(logit.subsetoldelos ), confint(logit.subsetoldelos )))

################################################################################################################

################################################################################################################
#to get the logistic regression for those below 60 years:
subet2=subset(model.design, admission_age.edited<60)
logit.subsetyounger <- (svyglm(mortality_90day~TREAT1ELSE0, family=quasibinomial(), design=subet2))
summary(logit.subsetyounger)
coef(logit.subsetyounger)
confint(logit.subsetyounger)
exp(cbind(OR = coef(logit.subsetyounger), confint(logit.subsetyounger)))

#to add in the los: 
logit.subsetyounger.los <- (svyglm(mortality_90day~TREAT1ELSE0+los_icu+los_hospital, family=quasibinomial(), design=subet2))
summary(logit.subsetyounger.los)
coef(logit.subsetyounger.los)
confint(logit.subsetyounger.los)
exp(cbind(OR = coef(logit.subsetyounger.los), confint(logit.subsetyounger.los)))
###############################################################################################################

###############################################################################################################
#####to do subgroup analysis on those with diff levels of ARDS:
subet3=subset(model.design, (hours48before.pao2fio2<=300)&(hours48before.pao2fio2>200))

#basic model
logit.subsetspf200to300.model1 <- (svyglm(mortality_90day~TREAT1ELSE0, family=quasibinomial(), design=subet3))
summary(logit.subsetspf200to300.model1)
coef(logit.subsetspf200to300.model1)
confint(logit.subsetspf200to300.model1)
exp(cbind(OR = coef(logit.subsetspf200to300.model1), confint(logit.subsetspf200to300.model1)))
#to add in los:
logit.subsetspf200to300.model2 <- (svyglm(mortality_90day~TREAT1ELSE0+los_icu+los_hospital, family=quasibinomial(), design=subet3))
summary(logit.subsetspf200to300.model2)
coef(logit.subsetspf200to300.model2)
confint(logit.subsetspf200to300.model2)
exp(cbind(OR = coef(logit.subsetspf200to300.model2), confint(logit.subsetspf200to300.model2)))

#*to do for those from 100 (inclusive) to 200
subet4=subset(model.design, (hours48before.pao2fio2<=200)&(hours48before.pao2fio2>100))

logit.subsetspf100to200.model1 <- (svyglm(mortality_90day~TREAT1ELSE0, family=quasibinomial(), design=subet4))
summary(logit.subsetspf100to200.model1)
coef(logit.subsetspf100to200.model1)
confint(logit.subsetspf100to200.model1)
exp(cbind(OR = coef(logit.subsetspf100to200.model1), confint(logit.subsetspf100to200.model1)))
#to add the los:
logit.subsetspf100to200.model2 <- (svyglm(mortality_90day~TREAT1ELSE0+los_icu+los_hospital, family=quasibinomial(), design=subet4))
summary(logit.subsetspf100to200.model2)
coef(logit.subsetspf100to200.model2)
confint(logit.subsetspf100to200.model2)
exp(cbind(OR = coef(logit.subsetspf100to200.model2), confint(logit.subsetspf100to200.model2)))

#for those ards where the pfratio<=100:
subet5=subset(model.design, (hours48before.pao2fio2<=100))
logit.subsetspfllesstan100.model1 <- (svyglm(mortality_90day~TREAT1ELSE0, family=quasibinomial(), design=subet5))
summary(logit.subsetspfllesstan100.model1)
coef(logit.subsetspfllesstan100.model1)
confint(logit.subsetspfllesstan100.model1)
exp(cbind(OR = coef(logit.subsetspfllesstan100.model1), confint(logit.subsetspfllesstan100.model1)))
#to add the los:
logit.subsetspfllesstan100.model2 <- (svyglm(mortality_90day~TREAT1ELSE0+los_icu+los_hospital, family=quasibinomial(), design=subet5))
summary(logit.subsetspfllesstan100.model2)
coef(logit.subsetspfllesstan100.model2)
confint(logit.subsetspfllesstan100.model2)
exp(cbind(OR = coef(logit.subsetspfllesstan100.model2), confint(logit.subsetspfllesstan100.model2)))

################################################################################################################
################################################################################################################
#to try on the secondary outcome: vent free days
boxplot(data.final$vent_free_days~data.final$TREAT1ELSE0)

#to conduct regression using the weighted data:
model.ventfreedays <- (svyglm(vent_free_days ~ TREAT1ELSE0, design = svydesign(~ 1, weights = ~ weight_create,
                                                                               data = data.final)))
summary(model.ventfreedays)
coef(model.ventfreedays)
confint(model.ventfreedays)

###to observe linear relationship between the outcome and the covariates that are to be added in. Using the original cohort.
plot(data.final$vent_free_days,data.final$los_icu )
plot(data.final$vent_free_days,data.final$los_hospital )

#to conduct regression using the weighted data with los variables added in:
model.ventfreedays.addvar <- (svyglm(vent_free_days ~ TREAT1ELSE0+los_icu+los_hospital, design = svydesign(~ 1, weights = ~ weight_create,
                                                                                                           data = data.final)))
summary(model.ventfreedays.addvar)
coef(model.ventfreedays.addvar)
confint(model.ventfreedays.addvar)
