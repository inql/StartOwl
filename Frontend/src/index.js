import './main.css';
import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';


const bkmKey = "save-bookmarks";
const catKey = "saved-categories";
const clocksKey = "saved-clocks";
const urlKey = "saved-urls";
const queriesKey = "saved-queries";
var storedName = localStorage.getItem('user-name');
var startName = "User";
if (storedName != null){
    startName = storedName;
}

var storedUrls = localStorage.getItem(urlKey)
if (storedUrls == null)
{
    storedUrls = ["www.polsatnews.pl"]
} else {
    storedUrls = storedUrls.split(",");
}

var storedBkms = localStorage.getItem(bkmKey);

var storedQueries = localStorage.getItem(queriesKey);
var storedCats = localStorage.getItem(catKey);
var storedClocks = localStorage.getItem(clocksKey);
var flags = [[startName, storedUrls, storedBkms], [storedCats, storedClocks, storedQueries]];

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

app.ports.storeShoppingQueries.subscribe(function(data){
    localStorage.setItem(queriesKey, JSON.stringify(data));
});

app.ports.storeBookmarks.subscribe(function(data){
    localStorage.setItem(bkmKey, JSON.stringify(data));
});

app.ports.storeUrls.subscribe(function(data)
{
    localStorage.setItem(urlKey, data);
});



// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
