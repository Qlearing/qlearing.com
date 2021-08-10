let header = document.getElementById('header');
let burger = document.querySelector('#headmenuburger')
// let headmenu = false;

 burger.addEventListener('click', ()=>{
     pushWindow("mobile-menu");
})


header.querySelector("#login-btn").addEventListener("click", ()=>{
    pushWindow("loginmenu")
})
header.querySelector("#reg-btn").addEventListener("click", ()=>{
    pushWindow("regmenu")
})

document.addEventListener("scroll", ()=>{
    if(pageYOffset>0){
        header.classList.add("fixed");
    }
    else{
        header.classList.remove("fixed");
    }
})