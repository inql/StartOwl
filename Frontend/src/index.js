import './main.css';
import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';

var catKey = "saved-categories";
var clocksKey = "saved-clocks";

var storedName = localStorage.getItem('user-name');
var startName = "User";
if (storedName != null){
    startName = storedName;
}

var storedCats = localStorage.getItem(catKey);
var storedClocks = localStorage.getItem(clocksKey);
var flags = [startName, storedCats, storedClocks];

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

app.ports.storeCategories.subscribe(function(data)
{
    localStorage.setItem(catKey, JSON.stringify(data));
    console.log(localStorage.getItem(catKey));  
});

app.ports.storeClocks.subscribe(function(data)
{
    localStorage.setItem(clocksKey, JSON.stringify(data));
    console.log(localStorage.getItem(clocksKey));  
});

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
