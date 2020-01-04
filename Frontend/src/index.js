import './main.css';
import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';

var storedName = localStorage.getItem('user-name');
var startName = "User";
if (storedName != null){
    startName = storedName;
}

var storedItems = localStorage.getItem("saved-items");

var flags = [startName, storedItems];

const app = Elm.Main.init({
  node: document.getElementById('root'),
  flags: flags
});


app.ports.storeName.subscribe(function(name) {
    if (name != "")
    {
        localStorage.setItem('user-name', name);
    }
    console.log(name);
});
app.ports.storeItems.subscribe(function(data)
{
    localStorage.setItem("saved-items", JSON.stringify(data));
    console.log(localStorage.getItem("saved-items"));  
});


// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
