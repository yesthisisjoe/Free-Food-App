//Parse.Cloud.afterSave("Posts", function(request) {
//    if (request.object.get("Approved")) {
//        //new free food post
//        if (request.object.get("FoodType").localeCompare("free") == 0) {
//            Parse.Push.send({
//                channels: ["FreePostNotifications"],
//                data: {
//                    alert: "New free food post: \"" + request.object.get("Title") + "\""
//                }
//            }, {
//                success: function() {
//                    console.log("Push successful")
//                },
//                error: function(error) {
//                    console.log("Push failed")
//                }
//            });
//        } else {
//            //new cheap food post
//            Parse.Push.send({
//                channels: ["CheapPostNotifications"],
//                data: {
//                    alert: "New cheap food post: \"" + request.object.get("Title") + "\""
//                }
//            }, {
//                success: function() {
//                    console.log("Push successful")
//                },
//                error: function(error) {
//                    console.log("Push failed")
//                }
//            });
//        }
//    }
//});
//
