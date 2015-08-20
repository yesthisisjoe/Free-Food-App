Parse.Cloud.beforeSave("Posts", function(request, response) {
    if (request.object.get("Rating") < 1) {
        response.error("yup, rating is less than 1");
    } else {
        response.success();
    }
});

Parse.Cloud.afterSave("Comment", function(request) {
                      Parse.Push.send({
                                      channels: [ "Giants", "Mets" ],
                                      data: {
                                      alert: "The Giants won against the Mets 2-3."
                                      }
                                      }, {
                                      success: function() {
                                      // Push was successful
                                      },
                                      error: function(error) {
                                      // Handle error
                                      }
                                      });                      });