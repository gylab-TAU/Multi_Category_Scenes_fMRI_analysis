rm(list = ls())

library(ggplot2)
library(dplyr)
library(lme4)
library(corrplot)
library(tidyr)
library(ggplot2)
library(ez)

setwd ("./")

dist_th = "0"
area = "LOC"

df_all = read.csv(paste ("../",area, "_all_voxles_excluding_neighbors_by_distance.csv", sep=""))


df_all$roi = factor(df_all$roi, levels = 1:12, labels = c("Face_dist", "Face_Body", "Face_Place", "Face_Body_Place",
                                       "Body_dist", "Body_Face", "Body_Place", "Body_Face_Place",
                                       "Place_dist", "Place_Face", "Place_Body", "Place_Face_Body"))


df_single_subj_length = aggregate(df_all[3], by=list(df_all$roi, df_all$subj), FUN = length)
names(df_single_subj_length)[names(df_single_subj_length) == "Group.1"] <- "roi"
names(df_single_subj_length)[names(df_single_subj_length) == "Group.2"] <- "subj"

df_subj_roi_size = spread(df_single_subj_length, subj, voxel_ind)


df_betas_long = gather(select(df_all, roi, subj, b_Face, b_Body, b_Chair,b_Room) ,"beta_cat","beta_value",3:6)
df_betas_long$beta_cat = as.factor(df_betas_long$beta_cat)
df_betas_long$beta_cat = relevel(df_betas_long$beta_cat, "b_Room")
df_betas_long$beta_cat = relevel(df_betas_long$beta_cat, "b_Body")
df_betas_long$beta_cat = relevel(df_betas_long$beta_cat, "b_Face")



df_single_subj_mean = aggregate(df_betas_long[4], by=list(df_betas_long$roi, df_betas_long$subj, df_betas_long$beta_cat), FUN = mean, na.rm=TRUE)
names(df_single_subj_mean)[names(df_single_subj_mean) == "Group.1"] <- "roi"
names(df_single_subj_mean)[names(df_single_subj_mean) == "Group.2"] <- "subj"
names(df_single_subj_mean)[names(df_single_subj_mean) == "Group.3"] <- "beta_cat"

df_group_subj_mean = aggregate(df_single_subj_mean[4], by=list(df_single_subj_mean$roi, df_single_subj_mean$beta_cat), FUN = mean, na.rm=TRUE)
names(df_group_subj_mean)[names(df_group_subj_mean) == "Group.1"] <- "roi"
names(df_group_subj_mean)[names(df_group_subj_mean) == "Group.2"] <- "beta_cat"

df_group_subj_sem = aggregate(df_single_subj_mean[4], by=list(df_single_subj_mean$roi, df_single_subj_mean$beta_cat), FUN = function(x) sd(x)/sqrt(length(x)))
names(df_group_subj_sem)[names(df_group_subj_sem) == "Group.1"] <- "roi"
names(df_group_subj_sem)[names(df_group_subj_sem) == "Group.2"] <- "beta_cat"

color_palette = c("b_Face" = "red1",
                  "b_Body" = "royalblue2",
                  "b_Chair" = "darkgoldenrod1",
                  "b_Room" = "green3")


# plot all roi's data:

roi_list = c("Face_dist", "Body_dist", "Face_Body", "Place_dist") # for VTC


for (roi_itr in 1:length(roi_list)){
  print(roi_list[roi_itr])
  curr_single_subj_mean = filter(df_single_subj_mean, roi == roi_list[roi_itr])
  curr_group_subj_mean = filter(df_group_subj_mean, roi == roi_list[roi_itr])
  curr_group_subj_sem = filter(df_group_subj_sem, roi == roi_list[roi_itr])
  
  gg = ggplot()
  
  gg = gg + geom_line(data = curr_single_subj_mean,
                      aes(x=beta_cat, y=beta_value, group=subj),
                      color = "grey70",
                      size=0.15)
  
  gg = gg + geom_point(data = curr_single_subj_mean,
                       aes(x=beta_cat, y=beta_value, color = beta_cat),
                       shape = 1,
                       size = 4,
                       position=position_jitter(width=0.1))
  
  # gg = gg + geom_point(data = df_group_subj_mean,
  #                      aes(x=beta_cat, y=beta_value, color = beta_cat),
  #                      shape = 18,
  #                      size = 8)
  gg = gg + geom_point(data = curr_group_subj_mean,
                       aes(x=beta_cat, y=beta_value, fill = beta_cat),
                       shape = 23,
                       size = 5,
                       color="black",
                       # alpha = 0.8,
                       stroke = 1)
  
  gg = gg + scale_colour_manual(values=color_palette)
  gg = gg + scale_fill_manual(values=color_palette)
  
  gg = gg + geom_errorbar(data = curr_group_subj_mean,
                          aes(x=beta_cat,
                              min=beta_value - curr_group_subj_sem$beta_value,
                              ymax=beta_value + curr_group_subj_sem$beta_value),
                          width=.2,
                          size = 0.5)
  
  
  
  gg = gg+ geom_hline(yintercept = 0, color="black", size=0.25)
  
  # gg = gg+scale_y_continuous(limits = c(-0.37, 1),
  #                            breaks = seq(-0, 1, by = 0.5))
  
  gg = gg+scale_y_continuous(limits = c(-0.6, 1.2),
                             breaks = seq(-0.5, 1, by = 0.5))
  
  # gg = gg + facet_wrap( ~ roi) 
  gg = gg+theme_minimal()
  
  gg = gg+ggtitle(roi_list[roi_itr])
  gg = gg+theme(axis.text = element_text(face = "italic", size = 16),
                axis.title.x=element_blank(),
                axis.text.x=element_blank(),
                axis.ticks.x=element_blank(),
                axis.title.y = element_blank())
  gg = gg+theme(legend.position="none")
  
  gg = gg + theme(strip.text.x = element_text(size = 20))
  
  print(gg)
  
  ggsave(gg, file=paste(area, "_", roi_list[roi_itr], "_dist_th_", dist_th, "_betas_new2.png", sep=""), width = 3.5, height = 3)
  
}




# Face & Body areas:
# ANOVA:
curr_betas = filter(df_single_subj_mean,
                    roi=="Face_dist"|
                    roi=="Face_Body" |
                    roi=="Body_dist")
ezDesign(data = curr_betas, x=subj, y=beta_cat, col =roi)

anova_results <- ezANOVA(curr_betas, # specify data frame
                         dv = beta_value, # specify dependent variable
                         wid = subj, # specify the subject variable
                         within = .(beta_cat, roi), # specify within-subject variables
                         detailed = TRUE # get a detailed table that includes SS
)
print(anova_results)


# t_tests:
curr_betas_wide = spread(curr_betas, beta_cat, beta_value)

curr_roi = filter(curr_betas_wide, roi=="Face_dist")
diff_vec = curr_roi$b_Face-(curr_roi$b_Body+curr_roi$b_Chair+curr_roi$b_Room)/3
t.test(diff_vec)
mean(diff_vec)/sd(diff_vec)

diff_vec = curr_roi$b_Face-curr_roi$b_Body
t.test(diff_vec)
mean(diff_vec)/sd(diff_vec)

diff_vec = curr_roi$b_Face-curr_roi$b_Chair
t.test(diff_vec)
mean(diff_vec)/sd(diff_vec)

diff_vec = curr_roi$b_Face-curr_roi$b_Room
t.test(diff_vec)
mean(diff_vec)/sd(diff_vec)



curr_roi = filter(curr_betas_wide, roi=="Body_dist")
diff_vec = curr_roi$b_Body-(curr_roi$b_Face+curr_roi$b_Chair+curr_roi$b_Room)/3
t.test(diff_vec)
mean(diff_vec)/sd(diff_vec)

diff_vec = curr_roi$b_Body-curr_roi$b_Face
t.test(diff_vec)
mean(diff_vec)/sd(diff_vec)

diff_vec = curr_roi$b_Body-curr_roi$b_Chair
t.test(diff_vec)
mean(diff_vec)/sd(diff_vec)

diff_vec = curr_roi$b_Body-curr_roi$b_Room
t.test(diff_vec)
mean(diff_vec)/sd(diff_vec)


curr_roi = filter(curr_betas_wide, roi=="Face_Body")
diff_vec = curr_roi$b_Face-curr_roi$b_Body
t.test(diff_vec)
mean(diff_vec)/sd(diff_vec)

curr_roi = filter(curr_betas_wide, roi=="Face_Body")
diff_vec = (curr_roi$b_Face+curr_roi$b_Body)/2-(curr_roi$b_Chair+curr_roi$b_Room)/2
t.test(diff_vec)
mean(diff_vec)/sd(diff_vec)

diff_vec = (curr_roi$b_Face+curr_roi$b_Body)/2-curr_roi$b_Chair
t.test(diff_vec)
mean(diff_vec)/sd(diff_vec)

diff_vec = (curr_roi$b_Face+curr_roi$b_Body)/2-curr_roi$b_Room
t.test(diff_vec)
mean(diff_vec)/sd(diff_vec)


# Place-Body areas
# Anova:
curr_betas = filter(df_single_subj_mean,
                      roi=="Body_dist" |
                      roi=="Place_dist")

  
  
ezDesign(data = curr_betas, x=subj, y=beta_cat, col =roi)

anova_results <- ezANOVA(curr_betas, # specify data frame
                         dv = beta_value, # specify dependent variable
                         wid = subj, # specify the subject variable
                         within = .(beta_cat, roi), # specify within-subject variables
                         detailed = TRUE # get a detailed table that includes SS
)

print(anova_results)


# t-tests:
curr_betas_wide = spread(curr_betas, beta_cat, beta_value)

curr_roi = filter(curr_betas_wide, roi=="Place_dist")
diff_vec = curr_roi$b_Room-(curr_roi$b_Body+curr_roi$b_Chair+curr_roi$b_Face)/3
t.test(diff_vec)
mean(diff_vec)/sd(diff_vec)

diff_vec = curr_roi$b_Room-curr_roi$b_Body
t.test(diff_vec)
mean(diff_vec)/sd(diff_vec)

diff_vec = curr_roi$b_Room-curr_roi$b_Chair
t.test(diff_vec)
mean(diff_vec)/sd(diff_vec)

diff_vec = curr_roi$b_Room-curr_roi$b_Face
t.test(diff_vec)
mean(diff_vec)/sd(diff_vec)



curr_roi = filter(curr_betas_wide, roi=="Body_dist")
diff_vec = curr_roi$b_Body-(curr_roi$b_Room+curr_roi$b_Chair+curr_roi$b_Face)/3
t.test(diff_vec)
mean(diff_vec)/sd(diff_vec)

diff_vec = curr_roi$b_Body-curr_roi$b_Face
t.test(diff_vec)
mean(diff_vec)/sd(diff_vec)

diff_vec = curr_roi$b_Body-curr_roi$b_Chair
t.test(diff_vec)
mean(diff_vec)/sd(diff_vec)

diff_vec = curr_roi$b_Body-curr_roi$b_Room
t.test(diff_vec)
mean(diff_vec)/sd(diff_vec)

