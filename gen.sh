swift package generate-xcodeproj
rpl -R "10.10" "10.14" `basename $PWD`.xcodeproj/
open ReplicantSwiftServer.xcodeproj
