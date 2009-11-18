# Needs capistrano task to execute whenever as follows:
# whenever  --load-file /full/path/to/rentcheck-website/vendor/extensions/site/config/schedule.rb 

every 2.hours do
   runner "SubscriptionManager.process"
end
 