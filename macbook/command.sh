# Disable relative dates
defaults write com.apple.finder RelativeDates -bool false
defaults write NSGlobalDomain AppleICUDateFormatStrings -dict-add "1" "yyyy-MM-dd HH:mm"
defaults write NSGlobalDomain AppleICUDateFormatStrings -dict-add "2" "yyyy-MM-dd HH:mm:ss"
defaults write NSGlobalDomain AppleICUDateFormatStrings -dict-add "3" "yyyy-MM-dd HH:mm:ss"
defaults write NSGlobalDomain AppleICUDateFormatStrings -dict-add "4" "yyyy-MM-dd HH:mm:ss"
killall Finder


## Validate
#defaults read com.apple.finder RelativeDates
# 0
#defaults read NSGlobalDomain AppleICUDateFormatStrings
# {
#     1 = "yyyy-MM-dd HH:mm";
#     2 = "yyyy-MM-dd HH:mm:ss";
#     3 = "yyyy-MM-dd HH:mm:ss";
#     4 = "yyyy-MM-dd HH:mm:ss";
# }


# Restore default
#defaults delete com.apple.finder RelativeDates
#defaults delete NSGlobalDomain AppleICUDateFormatStrings
#killall Finder
