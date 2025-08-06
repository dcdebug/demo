## show date in ISO format
# Usage:chmod +x ./show-iso-date.sh & ./show-iso-date.sh
defaults read com.apple.finder RelativeDates
# 0
defaults read NSGlobalDomain AppleICUDateFormatStrings
# {
#     1 = "yyyy-MM-dd HH:mm";
#     2 = "yyyy-MM-dd HH:mm:ss";
#     3 = "yyyy-MM-dd HH:mm:ss";
#     4 = "yyyy-MM-dd HH:mm:ss";
# }
