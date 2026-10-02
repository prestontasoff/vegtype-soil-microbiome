library(dplyr)
df <- data.frame(
  sample = c("H1a1", "H1a2", "H1c1", "H1c2", "H1m1", "H1m2", "H2a1", "H2a2", "H2c1", "H2c2", "H2m1", "H2m2",
             "H3a1", "H3a2", "H3c1", "H3c2", "H3m1", "H3m2", "L1a1", "L1a2", "L1c1", "L1c2", "L1m1", "L1m2",
             "L1s1", "L1s2", "L2a1", "L2a2", "L2c1", "L2c2", "L2m1", "L2m2", "L2s1", "L2s2", "L3a1", "L3a2",
             "L3c1", "L3c2", "L3m1", "L3m2", "L3s1", "L3s2", "U1a1", "U1a2", "U1c1", "U1c2", "U1m1", "U1m2",
             "U1s1", "U1s2", "U2a1", "U2a2", "U2c1", "U2c2", "U2m1", "U2m2", "U2s1", "U2s2", "U3a1", "U3a2",
             "U3c1", "U3c2", "U3m1", "U3m2", "U3s1", "U3s2"),
  unmapped_reads = c(47.356384,36.4808,22.736586,26.941563,44.814503,50.610226,44.156754,37.472893,28.644758,34.376633,37.623985,33.629585,44.70604,35.858242,33.984543,36.780327,51.571762,51.121815,48.6413,40.50987,36.24132,31.924755,50.835846,37.158142,56.686676,44.95691,39.218998,39.681507,30.162971,33.589382,60.35573,47.927795,49.87902,46.181946,43.437916,42.068344,50.36813,44.825596,42.498367,41.10629,47.973804,42.25676,34.386307,37.950535,35.4897,35.13951,40.43876,35.38974,42.94546,38.216286,38.45768,35.096752,35.30212,34.99652,47.260303,39.852375,50.298058,40.142506,47.44525,44.755165,31.878138,36.123253,41.138786,39.484203,43.364983,41.77861)
)


# Arrange the samples by the third character
df <- df %>%
  mutate(third_char = substr(sample, 3, 3)) %>%
  arrange(third_char, sample) %>%
  select(-third_char)  # remove the helper column

#Convert to mapped
df2 <- df %>%
  mutate(mapped_reads = 100- unmapped_reads) %>%
  select(sample, mapped_reads)

# Convert sample to a factor with the correct order
df2$sample <- factor(df2$sample, levels = df$sample)

# Plot a bar chart
p <- ggplot(df2, aes(x = sample, y = mapped_reads)) +
  geom_bar(stat = "identity") +
  labs(title = "Mapped Reads by Sample",
       x = "Sample",
       y = "Relabun Mapped Reads") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))


ggsave("/Users/ptasoff/My Drive/Preston_Projects/Vegtype/Analysis/Microtrait/coverm_genome/MAPPED_MEAN_samples.png", dpi = 300, plot = p)


# Custom colors for the groups
veg_colors <- c("a" = "#FFC125", "c" = "#6E8B3D", "m" = "#DDA0DD", "s" = "#CD5B45")

# Group by the third character and summarize the mean unmapped_reads
df_summary <- df2 %>%
  mutate(third_char = substr(sample, 3, 3)) %>%
  group_by(third_char) %>%
  summarize(mean_mapped_reads = mean(mapped_reads, na.rm = TRUE))

# Plot the summarized data with custom colors
ggplot(df_summary, aes(x = third_char, y = mean_mapped_reads, fill = third_char)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = veg_colors) +
  labs(title = "Relabun for Mean Mapped Reads by Group",
       x = "Group",
       y = "Relabun Mapped Reads") +
  theme(axis.text.x = element_text(angle = 0, vjust = 0.5, hjust = 0.5))

ggsave("/Users/ptasoff/My Drive/Preston_Projects/Vegtype/Analysis/Microtrait/coverm_genome/MAPPED_MEAN.png", dpi = 300)



coverm <- read.csv("/Users/ptasoff/My Drive/Preston_Projects/Vegtype/Analysis/Microtrait/coverm_genome/180923_coverm_output.txt", sep = "\t")
# Select columns that end with "Read Count"
coverm_reads <- coverm %>%
  select(ends_with("Read.Count"))

# Clean up column names
colnames(coverm_reads) <- gsub("_trim_clean_combined.PE.1.sort", "", colnames(coverm_reads))
colnames(coverm_reads) <- gsub("_trim_clean.PE.1.sort", "", colnames(coverm_reads))
colnames(coverm_reads) <- gsub(".Read.Count", "", colnames(coverm_reads))

# Print the cleaned data frame
print(coverm_reads)

# Summarize reads and create a new data frame
sum_sample_mapped_reads <- coverm_reads %>%
  summarize(across(everything(), sum, na.rm = TRUE))

# Print the summarized data frame
print(sum_sample_mapped_reads)
# Transpose the data frame
sum_sample_mapped_reads <- sum_sample_mapped_reads %>%
  pivot_longer(cols = everything(), names_to = "sample", values_to = "mapped_reads")

# Print the transposed data frame
print(sum_sample_mapped_reads)

#New one:
bam_stats <- read.csv("/Users/ptasoff/My Drive/Preston_Projects/Vegtype/Analysis/Microtrait/coverm_genome/bam_stats_updated_Nov2024.csv")
bam_stats


# Arrange the samples by the third character
bam_stats <- bam_stats %>%
  mutate(third_char = substr(sample, 3, 3)) %>%
  arrange(third_char, sample) %>%
  select(-third_char)  # remove the helper column

# Convert sample to a factor with the correct order
bam_stats$sample <- factor(bam_stats$sample, levels = bam_stats$sample)

#First see total reads
ggplot(data = bam_stats, aes(x = sample, y = Total.Reads, fill = third_char)) +
  geom_bar(stat = "identity")

# Plot a bar chart
p <- ggplot(bam_stats, aes(x = sample, y = Percent.Mapped)) +
  geom_bar(stat = "identity") +
  labs(title = "Mapped Reads by sample",
       x = "sample",
       y = "Count Mapped Reads") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))


ggsave("/Users/ptasoff/My Drive/Preston_Projects/Vegtype/Analysis/Microtrait/coverm_genome/MAPPED_bam_stats_Files.png", dpi = 300, plot = p)


# Custom colors for the groups
veg_colors <- c("a" = "#FFC125", "c" = "#6E8B3D", "m" = "#DDA0DD", "s" = "#CD5B45")

# Group by the third character and summarize the mean mapped_reads
bam_stats_summary <- bam_stats %>%
  mutate(third_char = substr(sample, 3, 3)) %>%
  group_by(third_char) %>%
  summarize(mean_mapped_read_percent = mean(Percent.Mapped, na.rm = TRUE),
            median_mapped_read_percent = median(Percent.Mapped, na.rm = TRUE))

# Plot the summarized data with custom colors
ggplot(bam_stats_summary, aes(x = third_char, y = mean_mapped_read_percent, fill = third_char)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = veg_colors) +
  labs(title = "Mean Mapped Read Percent by Group",
       x = "Group",
       y = "Mapped Reads") +
  theme(axis.text.x = element_text(angle = 0, vjust = 0.5, hjust = 0.5))

ggsave("/Users/ptasoff/My Drive/Preston_Projects/Vegtype/Analysis/Microtrait/coverm_genome/MAPPED_MEAN.png", dpi = 300)

#Median
ggplot(bam_stats_summary, aes(x = third_char, y = median_mapped_read_percent, fill = third_char)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = veg_colors) +
  labs(title = "Median Mapped Read Percent by Group",
       x = "Group",
       y = "Mapped Reads") +
  theme(axis.text.x = element_text(angle = 0, vjust = 0.5, hjust = 0.5))
