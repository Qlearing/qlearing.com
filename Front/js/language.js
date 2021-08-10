let languageswitcher = document.getElementsByClassName('language-switcher');

for(let i of languageswitcher){
    i.addEventListener("click", ()=>{
        pushWindow('lang-menu')
    });
}