var web3Provider;
var account;
var airbnbContract;
var chainId;
let web3;
$(async () => {
    console.log("connect.js page running...");

    if(window.ethereum){
        web3Provider = window.ethereum;
        console.log("window.ethereum ===> ",web3Provider);
        try{
            // This will request for account access on metamask
            await window.ethereum.enable();
        }catch(error){
            console.log("Use denided account access");
        }
    }
    else if(window.web3){
        web3Provider = window.web3.currentProvider;
        console.log("window.web3 ===> ",web3Provider);
    }
    else{
        alert("No injected web3 browser detected!,\nplease install one.");
    }

    await loadAccount();

    await loadContract();

    await airbnbContract.methods.propertyId().call()
    .then(async(result) => {
        for(let i=0; i<result;i++){
            let object = await airbnbContract.methods.allProperties(i).call();
            $("#cardsHolder").append(`
            <div class="card ml-4" style="width: 200px;">
                <img class="card-img-top" src="./img-property.png" alt="Card image cap">
                <div class="card-body">
                    <h5 class="card-title">${object.name}</h5>
                    <p class="card-text">${object.description}</p>
                    <p class="card-text">Price: ${object.price}</p>
                    <p class="card-text">Status: <small class="text-muted text-light">${object.isActive}</small></p>
                    <a href="#" class="btn btn-primary">Reserve</a>
                </div>
            </div>`);   
        } 
    })
    .catch((error) => {
        alert("!Error while getting the Properties from Blockchain");
    });
});

async function loadAccount(){
    web3 = new Web3(web3Provider);
    let accounts = await web3.eth.getAccounts();
    account = accounts[0];
    console.log("Accounts ==>> ",account);
    $("#account").html(account);
}

async function loadContract(){
    let contractAddress = "0x827cC80B81e3F7bd885EBAbC139b1F3aDC162C3B";
    let artifact = await $.getJSON('Airbnb.json');
    airbnbContract = await new web3.eth.Contract(artifact.abi, contractAddress);
    console.log("Contract ===> ",airbnbContract);
}

$("#submitBtn").on('click', async () => {
    let sName = $("#pNameInput").val();
    let sDescription = $("#pDescriptionInput").val();
    let nPrice = $("#pPriceInput").val();

    await airbnbContract.methods.rentOutProperty(sName, sDescription, nPrice).send({from: account}, (error, receipt) => {
        if(error)
            alert("!Error while making the transaction with the Blockchain");
        else{
            $("#cardsHolder").append(`
            <div class="card ml-2" style="width: 200px;">
                <img class="card-img-top" src="./img-property.png" alt="Card image cap">
                <div class="card-body">
                    <h5 class="card-title">${sName}</h5>
                    <p class="card-text">${sDescription}</p>
                    <p class="card-text">Price: <small class="text-muted">${nPrice}</small></p>
                    <p class="card-text">Status: <small class="text-muted text-light">true</small></p>
                    <a href="#" class="btn btn-primary">Reserve</a>
                </div>
            </div>`);
        }
    });
});


ethereum.on('chainChanged', async (chainId) => {
    chainId = chainId;
    window.location.reload();
});

ethereum.on('accountsChanged', function (accounts) {
    console.log("New Account ==>> ",accounts[0]);
    account = accounts[0];
    window.location.reload();
});