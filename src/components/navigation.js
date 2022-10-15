import React from "react";

export const NavigationBar = (props) => {

  return <div>



    
    <nav class="navbar">
        <div class="container-fluid">
        <span class="navbar-brand m-0 fw-bold text-white"
            ><h1>dArt</h1></span
          >
          <span class="nav-link border rounded-pill bg-light">
            <span id='balance'>{props.cUSDBalance}</span>
            cUSD
          </span>
        </div>
      </nav>
  
		</div>
	
};
