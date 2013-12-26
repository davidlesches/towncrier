(function() {
  window.townCry = {};

  townCry.hear = function(name, action, payload) {
    var json;
    json = $.parseJSON(payload);
    if (("hear" + name) in townCry) {
      return townCry["hear" + name](action, json);
    }
  };

}).call(this);