(function() {
  window.towncrier = {};

  towncrier.hear = function(name, action, payload) {
    var json;
    json = $.parseJSON(payload);
    if (("hear" + name) in towncrier) {
      return towncrier["hear" + name](action, json);
    }
  };

}).call(this);