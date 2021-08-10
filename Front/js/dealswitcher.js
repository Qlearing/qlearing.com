let dealswitchers = document.getElementsByClassName("deal-switcher");
let dealcontainers = document.getElementsByClassName("dealcontainer")

for(let switcher of dealswitchers){
    switcher.addEventListener('click', (e)=>{
        e.preventDefault()
        location.href = switcher.href;
        checkdeals();
    })
}

function checkdeals(group){
    if(!group){
        if (location.href.match('all-deals')) {
            group = 0;
        }
        else if (location.href.match('opened-deals')) {
            group = 1;
        }
        else if (location.href.match('disput-deals')) {
            group = 2;
        }
        else if (location.href.match('drafts-deals')) {
            group = 3;
        }
        else if (location.href.match('closed-deals')) {
            group = 4;
        }
        else{
            group = 0;
        }

        for(let i of dealswitchers){
            i.classList.remove("selected");
        }
        for(let i of dealcontainers){
            i.classList.add("hidden");
        }
        dealcontainers[group].classList.remove("hidden");
        dealswitchers[group].classList.add("selected");
    }
    else{
        for(let i of dealswitchers){
            i.classList.remove("selected");
        }
        for(let i of dealcontainers){
            i.classList.add("hidden");
        }
        dealcontainers[group].classList.remove("hidden");
        dealswitchers[group].classList.add("selected");
    }
}

checkdeals()
