var fbConfigurator = angular.module('fbConfigurator', []);
fbConfigurator.controller('ConfiguratorController', function ConfiguratorController($scope, $http) {
  $scope.url = "http://" + location.host;
  $scope.ssids = [];
  $scope.should_use_ethernet = false;
  $scope.should_use_wifi = false;
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
    server = document.getElementById("fbserver").value;
    port = document.getElementById("fbport").value;
    tz = document.getElementById("timezonemenu").value;
    realSrv = "http://" + server + ":" + port;

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

    if(email != ""){
      console.log(JSON.stringify(json));
      $http.post($scope.url + "/login", json).then(function(resp){
        console.log("Should never see this...");
      }).catch(function(error){
        console.log("will probably see this a lot...");
        console.log(JSON.stringify(error));
      });
    }
  };
})
.controller('SecretController', function SecretController($scope, $http){
  $scope.url = "http://" + location.host;
  var box = document.getElementById("box");
  function open(){
    $scope.websocket = new WebSocket('ws://localhost:4000/ws');
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
