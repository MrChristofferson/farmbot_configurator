var fbConfigurator = angular.module('fbConfigurator', []);
fbConfigurator.controller('ConfiguratorController', function ConfiguratorController($scope, $http) {
  $scope.url = "http://" + location.host;
  $scope.ssids = [];
  $scope.should_use_ethernet = false;
  $scope.should_use_wifi = false;
  $scope.showErrors = false;
  $scope.info = "";
  $scope.secret_counter = 0;

  $scope.show_info = function(){
    $scope.secret_counter = $scope.secret_counter + 1
    console.log($scope.secret_counter)
    if($scope.secret_counter == 5){
      $http.get($scope.url + "/info").then(function(resp){
        console.log(resp.data);
        $scope.info = resp.data;
      })
    }
  }

  $http.get($scope.url + "/scan").then(function(resp){
    console.log(resp.data);
    $scope.ssids = resp.data;
  }).catch(function(error){
    console.log("not running on device?");
    $scope.ssids = [];
  })

  $scope.select_ssid = function(ssid){
    $scope.should_use_wifi = true;
    $scope.should_use_ethernet = false;
    document.getElementById("wifissid").value = ssid;
  };

  $scope.toggle_ethernet = function() {
    if(!$scope.should_use_ethernet){
      $scope.should_use_wifi = false;
      $scope.should_use_ethernet = true;
    } else {
      $scope.should_use_wifi = true;
      $scope.should_use_ethernet = false;
    }

  };

  $scope.submit = function(){
    email = document.getElementById("fbemail").value;
    password = document.getElementById("fbpwd").value;
    protocol = document.getElementById("protocol").value;
    server = document.getElementById("fbserver").value;
    port = document.getElementById("fbport").value;
    tz = document.getElementById("timezonemenu").value;
    realSrv = protocol + server + ":" + port;

    json = {
      "email": email,
      "password": password,
      "server": realSrv,
      "tz": tz,
    };
    if($scope.should_use_ethernet){
      json["network"] = "ethernet"
    } else {
      ssid = document.getElementById("wifissid").value;
      psk = document.getElementById("wifipsk").value;
      json["network"] = {
        "ssid": ssid,
        "psk": psk
      }
    }

    var EMAIL_REGEX = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    if(EMAIL_REGEX.test(email)){
      console.log(JSON.stringify(json));
      $http.post($scope.url + "/login", json).then(function(resp){
        console.log("Should never see this...");
      }).catch(function(error){
        console.log("will probably see this a lot...");
        console.log(JSON.stringify(error));
      });
    } else {
      $scope.showErrors = true;
    }
  };
})
.controller('SecretController', function SecretController($scope, $http){
  $scope.url = "http://" + location.host;
  var box = document.getElementById("box");
  function open(){
    $scope.websocket = new WebSocket('ws://'+ location.host + location.port + '/ws');
  };
  open();

  $scope.websocket.onopen = function(evt) { onOpen(evt) };
  $scope.websocket.onclose = function(evt) { onClose(evt) };
  $scope.websocket.onmessage = function(evt) { onMessage(evt) };

  $scope.do_thing = function(){
    var val = document.getElementById("shellbox").value
    box.value = box.value + " " + val;
    $scope.websocket.send(val);
    document.getElementById("shellbox").value = "";
  }

  function onMessage(evt) {
    // box.rows = box.rows + 1
    box.value = box.value + "\n " + evt.data + "\n >>";
  };

  function disconnect() {
    $scope.websocket.close();
  };

  function onOpen(evt) {
    console.log("CONNECTED");
    box.value = "CONNECTED\n >>"
  };

  function onClose(evt) {
    console.log("DISCONNECTED")
  };
});
