#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Rshiny ideas from on https://gallery.shinyapps.io/multi_regression/
# https://stats.stackexchange.com/questions/28876/difference-between-anova-power-simulation-and-power-calculation

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
library(ggplot2)
library(shiny) 
library(nlme)
library(VCA)
library(shinyWidgets)

options(max.print=1000000)
fig.width <- 1200
fig.height <- 450
library(shinythemes)        # more funky looking apps
p1 <- function(x) {formatC(x, format="f", digits=1)}
p2 <- function(x) {formatC(x, format="f", digits=2)}
is.even <- function(x){ x %% 2 == 0 }
options(width=100)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ui <- fluidPage(theme = shinytheme("paper"), #https://www.rdocumentation.org/packages/shinythemes/versions/1.1.2
                
                setBackgroundColor(
                    color = c("#d7d7ce", "#d3ced7"),  
                    gradient = "radial",
                    direction = c("bottom", "left")
                ),                
                shinyUI(pageWithSidebar(
                    
                    #ui <-shinyUI(pageWithSidebar(
                    
                    h3("Power for one way analysis of variance"),
                    #headerPanel("Power for one way analysis of variance"),
                    
                    #sidebarLayout(  #new
                    # Sidebar with a slider and selection inputs
                    
                    sidebarPanel( 
                        
                        div(p("If a researcher is interested in evaluating if there is a
                        difference in the population means between groups a common statistical
                        tool that is used is analysis of variance (ANOVA). Here we investigate power for one way ANOVA.
              ")),
                        
                        div(
                            
                            selectInput("Plot",
                                        strong("Select plot preference "),
                                        choices=c("ggplot", "VCA package plot" )),
                            
                            selectInput("Model",
                                        strong("Select modelling preference "),
                                        choices=c( "base R" , "VCA package" )),
                            
                            
                            # sidebarPanel(
                            #    actionButton("read", "Change"),  # new
                            #   actionButton("write", "Change"),  #new
                            #),
                            
                            # actionButton("resample", "Simulate a new sample"),
                            # br(),br(),
                            # 
                            # actionButton(inputId='ab1', label="R code here", 
                            #              icon = icon("th"), 
                            #              onclick ="window.open('https://raw.githubusercontent.com/eamonn2014/One-way-ANOVA/master/app.R', '_blank')"),
                            
                            br(),
                            actionButton(inputId='ab1', label="R code",   icon = icon("th"), 
                                         onclick ="window.open('https://raw.githubusercontent.com/eamonn2014/One-way-ANOVA/master/app.R', '_blank')"),   
                            actionButton("resample", "Simulate a new sample"),
                            br(), br(),
                            
                    
                            div(strong("Select true population parameters"),p(" ")),
                            
                            
                            div((" We can vary the number independent of groups, 
                            the size of each group, the true group 
                              means and standard deviations. We use simulations to estimate power. 
                              The number of simulations  can be varied along with 
                              the so called significance level.
                            
                            
                            The first tab plots the data and presents an ANOVA and the power estimates. 
                 Above you can select between two plots. 
                                 There is also an option to look at the output of the VCA package
                                 'Select modelling preference'. Another sample can be taken from the 
                                 same population/data generating mechanisim by clicking 'Simulate a new sample'.")),
                            br(),
                            
                        
                            
                            sliderInput("top",
                                        "Select the number of independent groups",
                                        min=3, max=10, step=1, value=4, ticks=FALSE),
                            
                            sliderInput("range1", "Select group sizes: randomly select using range or uniquely select:", 
                                        min = 2, max = 50, value = c(25, 25), ticks=FALSE) ,
                            
                            sliderInput("range2", "Select true group means: randomly select using range or uniquely select:",
                                        min = -100, max = 100, value = c(45, 50),ticks=FALSE),
                            
                            sliderInput("range3", "Select true group standard deviations: randomly select using range or uniquely select",
                                        min = 2, max = 15, value = c(5, 5), ticks=FALSE),
                            sliderInput("simulate",
                                        "Select the number of simulations",
                                        min=999, max=9999, step=1000, value=1999, ticks=TRUE),
                            sliderInput("alpha",
                                        "Select the significance level",
                                        min=0.01, max=0.40, step=0.01, value=0.05, ticks=FALSE)
                            
                        )
                    ),
                    
                    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~tab panels
                    mainPanel(
                        
                        #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        #    tabsetPanel(type = "tabs", 
                        navbarPage(       
                            #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  
                            tags$style(HTML(" 
                            .navbar-default .navbar-brand {color: cyan;}
                            .navbar-default .navbar-brand:hover {color: blue;}
                            .navbar { background-color: lightgrey;}
                            .navbar-default .navbar-nav > li > a {color:black;}
                            .navbar-default .navbar-nav > .active > a,
                            .navbar-default .navbar-nav > .active > a:focus,
                            .navbar-default .navbar-nav > .active > a:hover {color: pink;background-color: purple;}
                            .navbar-default .navbar-nav > li > a:hover {color: black;background-color:yellow;text-decoration:underline;}
                            .navbar-default .navbar-nav > li > a[data-value='t1'] {color: red;background-color: pink;}
                            .navbar-default .navbar-nav > li > a[data-value='t2'] {color: blue;background-color: lightblue;}
                            .navbar-default .navbar-nav > li > a[data-value='t3'] {color: green;background-color: lightgreen;}
                   ")), 
                            #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~end of section to add colour     
                            tabPanel("Plot and ANOVA", 
                                     
                                     div(plotOutput("reg.plot", width=fig.width, height=fig.height)),  
                                     p(strong("The data distributions are summarised using ggplot2 boxplots with whiskers that extend to the most 
                                     remote point that is not an 'outlier' (beyond 1.5 IQR from the quartiles) otherwise 1.5 x IQR from the quartiles. The raw data is also presented.")),
                                   #  p(strong("We calculate power using the R power.anova.test function  (for balanced designs). 
                                    # The balanced one-way analysis of variance power calculation function will only work correctly when the within group SDs the same.")),
                                    # div( verbatimTextOutput("p1")),
                                     p(strong("The simulation approach power estimate below takes into account different group sizes and different SDs within groups. 
                                     Note hitting 'Select a new sample' even when the input sliders 
                                     remain the same generates a new sample based on the range 
                                              sliders so the randomly chosen group means and SDs are unlikely to be the same, hence the power returned is for a new data generating mechanism and is not 
                                              expected to resemble the previous power estimate.")),
                                     div( verbatimTextOutput("p2")),
                                     div( verbatimTextOutput("reg.summary"))
                                     
                            ) ,
                            #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                
                            #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                            tabPanel("Check assumptions", 
                                     
                                     p(strong("Is there evidence that the residuals are skewed or otherwise mis shapen
                in a way that would influence the results? Note, our sample will be imperfect and our population
                will not necessarily be 'perfectly normal' either.
                Here we prefer simple plotting to look for an unspecifiable amount of
                non normality that may help look into any issues rather than a formal approach using statistical tests.")),
                                     
                                     div(plotOutput("residual", width=1200, height=800)) ,
                            ) ,
                            
                            #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                            tabPanel("List the data", 
                                     
                                     p(strong("IV is the independent variable, DV is the dependent variable. mu and sd are just for information and are the true mean and sd for each IV group.")),
                                     
                                     div( verbatimTextOutput("summary2")),
                                     
                            ),
                            #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                            tabPanel("True means, standard deviations and group counts", 
                                     
                                     p(strong("mu and sd are the true mean and sd for each IV group and n the number of observations in each group.")),
                                     
                                     div( verbatimTextOutput("summary3")),
                                     
                            )
                        )
                        #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    )
                    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~end tab panels
                    
                    #  ) #new
                )
                )
)

server <- shinyServer(function(input, output) {
    
    # --------------------------------------------------------------------------
    # This is where a new sample is instigated only random noise is required to be generated
    random.sample <- reactive({
        
        # Dummy line to trigger off button-press
        foo <- input$resample
        
        x1 <- input$range1[1]  #size
        x2 <- input$range1[2]
        x3 <- input$range2[1]  #mean
        x4 <- input$range2[2]
        x5 <- input$range3[1]  #sd
        x6 <- input$range3[2]
        
        top <-  input$top  # number of groups
        
        # seems that I need to use both c(x1,x2) c(x1:x2) so sample function works correctly
        
        if (x1==x2) {
            
            middle <-  sample(c(x1,x2),   top, replace=TRUE)    # choose top count between sliders 
            
        } else {
            
            middle <-  sample(c(x1:x2),   top, replace=TRUE)    #  
        }
        
        
        if (x3==x4) {
            
            lower <-   sample(c(x3,x4),   top, replace=TRUE )  #group means
            
        } else {
            
            lower <-   sample(c(x3:x4),  top, replace=TRUE )  # groups means 
            
        }
        
        if (x5==x6) {
            
            replicates <-  sample(c(x5,x6),  top, replace=TRUE )   #group sds
            
        } else {
            
            replicates <-  sample(c(x5:x6),   top, replace=TRUE )   #grp sds
            
        }
        
        return(list( 
            middle=middle, top=top, lower=lower, replicates=replicates
        ))
        
    }) 
    
    # --------------------------------------------------------------------------
    # Set up the dataset based on the inputs 
    make.regression <- reactive({
        
        #   https://stats.stackexchange.com/questions/28876/difference-between-anova-power-simulation-and-power-calculation
        
        sample <- random.sample()
        
        top <-        sample$top
        middle <-     sample$middle
        lower <-      sample$lower
        replicates <- sample$replicates
        
        Nj    <- sum(middle)                  # sum each group size 
        
        muJ   <- rep(lower, rep(middle))      # expand means by group sizes
        
        sds   <- rep(replicates, rep(middle)) # expand sd by group sizes
        
        grpnames <- LETTERS[1:top]
        
        IV <- factor( rep( grpnames, rep(middle) ) )
        
        d <- data.frame(IV=IV,
                        mu= muJ, 
                        sd= sds,
                        x=1
        )
        
        d$DV = rnorm(d$x, d$mu, d$sd)  # create the response
        
        df <- as.data.frame(d)
        
        dd <- plyr::arrange(df, IV)    # sort and create for better order
        
        dd$x <- NULL
        
        # make concise dataset of true means and sds
        ddd <- dd
        ddd$DV <- NULL
        ddd <- unique(ddd)
        ddd$n <- as.vector(table(dd$IV))
        rownames(ddd) <- NULL
        
        
        
        
        return(list(df=df, dd=dd, ddd=ddd)) 
        
    })  
    
    # --------------------------------------------------------------------------
    
    # --------------------------------------------------------------------------
    # Set up the dataset based on the inputs 
    make.power <- reactive({
        
        
        sample <- random.sample()
        
        top <-        sample$top
        middle <-     sample$middle
        lower <-      sample$lower
        replicates <- sample$replicates
        alpha <- input$alpha
        nsims <- input$simulate
        
        mu <- lower
        sigma <- replicates
        Nj <- middle
        
        mus    <- rep(mu, times=Nj)             # for use in rnorm(): vector of mus
        sigmas <- rep(sigma, times=Nj)          # for use in rnorm(): vector of true sds
        IV     <- factor(rep(1:top, times=Nj))    # factor for ANOVA
       # nsims  <- 4999                          # number of simulations
        
        # reference: correct power
        power.func <- power.anova.test(groups=top, n=Nj[1], sig.level =alpha,
                         between.var=var(mu), within.var=sigma[1]^2)$power
        
        doSim <- function() {                   # function to run one ANOVA on simulated data
            DV <- rnorm(sum(Nj), mus, sigmas)   # data from all three groups
            anova(lm(DV ~ IV))["IV", "Pr(>F)"]  # p-value from ANOVA
        }
        
        pVals  <- replicate(nsims, doSim())     # run the simulation nsims times
        
        power.sim <- sum(pVals < alpha) / nsims      # fraction of significant ANOVAs
        
        
        boxplot( rnorm(sum(Nj), mus, sigmas) ~IV   )
       
        return(list(power.func=power.func, power.sim=power.sim)) 
        
    })  
    
    # --------------------------------------------------------------------------
    
    
    
    # Fit the specified regression model
    fit.regression <- reactive({
        
        data <- make.regression()
        
        df <- data$df
        
        #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        # Conditionally fit the model
        
        if (input$Model == "base R") {
            
            fit.res <-  
                tryCatch(aov(DV ~IV, df), 
                         error=function(e) e)
            
            #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            ###http://stackoverflow.com/questions/8093914
            ###/skip-to-next-value-of-loop-upon-error-in-r-trycatch
            
            if (!inherits(fit.res, "error")) {
                
                ff <- fit.res
                fit.res <-  anova(fit.res) # for the residuals
                
                df.b     <- fit.res[['Df']][1] 
                df.w     <- fit.res[['Df']][2] 
                ss.b     <- fit.res[['Sum Sq']][1]
                ss.w     <- fit.res[['Sum Sq']][2]
                ms.b     <- fit.res[['Mean Sq']][1]
                ms.w     <- fit.res[['Mean Sq']][2]
                f        <- fit.res[['F value']][1]
                p        <- fit.res[['Pr(>F)']][1]
                
                
            } else  {
                
                fit.res <- NULL
                ff <- NULL
                
            }
            #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        } else if (input$Model == "VCA package") {          
            #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            
            o <- fit.res<- tryCatch(anovaVCA(DV~IV, df), 
                                    error=function(e) e) 
            
            #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            if (!inherits(fit.res, "error")) {
                
                fit.res <- VCAinference(fit.res, ci.method = "sas")
                ff <- fit.res
                x <- as.matrix(o)
                features <- attributes(x)
                
                emu      <-  (features$Mean) 
                
                o <- as.matrix(o)
                
                df.b     <-  (o["IV",   "DF"])
                df.w     <-  (o["error","SD"])
                ss.b     <-  (o["IV"   ,"SS"])
                ss.w     <-  (o["error","SS"])
                ms.b     <-  (o["IV"   ,"MS"])
                ms.w     <-  (o["error","MS"])
                f        <-  NULL
                p        <-  NULL
                
                
            } else  {
                
                fit.res <- NULL
                
            }
        }
        #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
        # Get the model summary
        if (is.null(fit.res)) {
            
            fit.summary <- NULL
            
        } else {
            
            fit.summary <-  (fit.res)
        }
        
        return(list(df.b=df.b, df.w=df.w, ss.b=ss.b, 
                    ss.w=ss.w,ms.b=ms.b,ms.w=ms.w,f=f,p=p,
                    fit.res=fit.res, fit.summary=fit.summary, ff=ff
                    
        ))
        
    })     
    
    # --------------------------------------------------------------------------
    # Set up the dataset based on the inputs 
    explain <- reactive({
        
        data <- make.regression()
        
        df <- data$df
        
        #### useful statistics
        Nj        <- length(df$DV)                # total no of observations
        Grandmean <- mean(df$DV)                  # grand mean
        grpn      <- tapply(df$DV, df$IV, length) # group sizes
        no.grps   <- length(names(table(  df$IV)))# no of groups
        means     <- tapply(df$DV, df$IV, mean)   # group means
        vars      <- tapply(df$DV, df$IV, var)    # group variances
        
        # simple approiach only for balanced designs
        # estimate sigma2 using a pooled estimate of the variance of each group
        ms.wb <-sum(vars)/no.grps
        
        # we have another way , if the 4 means do not differ the sample means are normally
        # distributed with variance sigma2/group size. sigma2/group size can be estimated by the
        # variance of the smaple means
        # so group size x the above is another estimate of sigma2
        
        ms.bb <- var(means)*unique(grpn)
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        # more generally, if groups are of different sizes...
        # within sum of squares
        ss.w <- sum( (grpn-1) * vars )
        
        # within df
        df.w <- Nj -  no.grps
        
        # mean square within
        ms.w <- ss.w /df.w
        
        # between sum of squares
        ss.b <- sum(grpn * (means - Grandmean)^2)
        
        # between df
        df.b <- no.grps -1
        
        # mean square between
        ms.b <- ss.b /df.b
        
        #pvalue
        pv  <- 1 - pf( ms.b/ms.w, df.b, df.w)
        
        A <- c(  df.b,   ss.b, ms.b, ms.b/ms.w, pv , ms.bb)
        B <- c(  df.w  , ss.w, ms.w, NA,        NA , ms.wb)
        
        ANOVA <- NULL
        ANOVA <- as.data.frame(rbind(A,B))
        
        n1 <- c("Df","Sum Sq","Mean Sq","F value","Pr(>F)", "Mean Sq balanced only")
        n2 <- c("IV","Residuals")
        
        colnames(ANOVA) <- n1
        rownames(ANOVA) <- n2
        
        ANOVA <-  as.data.frame(ANOVA[,1:6])
        ANOVA2 <-  as.data.frame(ANOVA[,1:5])
        
        return(list( ANOVA=ANOVA, ANOVA2=ANOVA2)) 
    })  
    
    # --------------------------------------------------------------------------
    #---------------------------------------------------------------------------
    # Plot a scatter of the data  
    
    output$reg.plot <- renderPlot({         
        
        # Get the current regression data
        data1 <- make.regression()
        
        df <- data1$df
        
        # Conditionally plot
        if (input$Plot == "ggplot") {
            
            #base plot~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            #https://rstudio-pubs-static.s3.amazonaws.com/308410_2ece93ee71a847af9cd12fa750ed8e51.html
            
            ggplot(df, aes(reorder(IV,DV),DV,fill=IV))+
                # ggplot(tyre, aes(Brands,Mileage,fill=Brands))+ # if you want to leave them alphabetic
                
                stat_boxplot(geom ='errorbar',width = 0.4) +
                geom_boxplot(outlier.shape = NA) + #avoid duplication of outliers
                labs(title="Boxplot, dotplot and Standard error of mean for groups", 
                     x = "Groups (sorted)",
                     y = "Response",
                     subtitle ="Gray dots=sample data points, Blue dot=mean, Red=99% confidence interval",
                     caption = "") +
                guides(fill=FALSE) +
                geom_jitter(shape=21, fill="blue", color="darkred", size=3, width= 0.1) +
                stat_summary(geom="point", fun.y=mean, color="blue") +
                stat_summary(fun.data = "mean_cl_normal", colour = "red", size = 1.5, 
                             fun.args = list(conf.int=.99)) +
                
                theme_bw() 
            
        } else {
            
            #VCA plot~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            
            varPlot(DV~IV, df, 
                    BG=list(var="IV", 
                            col=c("#f7fcfd","#e5f5f9","#ccece6","#99d8c9",
                                  "#66c2a4","#41ae76","#238b45","#006d2c","#00441b"), 
                            col.table=TRUE), 
                    VLine=list(var=c("IV"), 
                               col=c("black", "mediumseagreen"), lwd=c(2,1), 
                               col.table=c(TRUE,TRUE)), 
                    JoinLevels=list(var="IV", col=c("lightblue", "cyan", "yellow"), 
                                    lwd=c(2,2,2), 
                                    MeanLine=list(var="DV", col="blue", lwd=2) ,
                                    
                                    # Title=list(main=paste("Variability Chart. Truth (estimate): intercept "
                                    #                       ,input$intercept,"(",fit.regression()$emu,"), top level sd=",
                                    #            input$a,"(",fit.regression()$etop,")", ",\n middle level sd=",
                                    #            input$b ,"(",fit.regression()$eday,"), lowest level sd=",
                                    #            input$c, "(",fit.regression()$erun,") & random error sd=", 
                                    #            input$d,"(",fit.regression()$esigma,")")),
                                    
                                    # MeanLine=list(var="mid", col="pink", lwd=2),
                                    Points=list(pch=list(var="mid", pch=c(21, 22, 24)), 
                                                bg =list(var="mid", bg=c("lightblue", "cyan", "yellow")), 
                                                cex=1.25))    )
        }
        
    })
    #---------------------------------------------------------------------------
    #--------------------------------------------------------------------------
    #---------------------------------------------------------------------------
    # Plot residuals 
    
    output$residual <- renderPlot({         
        
        # Get the current regression model
        d  <- fit.regression()
        
        f<- d$ff
        
        par(mfrow=c(3,2))
        plot(f)
        
        #dd <- d$fit.res
        anova.residuals <- residuals( object =  f) # extract the residuals
        # A simple histogram
        hist( x = anova.residuals , breaks=50, main=paste("Histogram of ANOVA residuals, SD=",p2(sd(anova.residuals)),"")) # another way of seeing residuals
        par(mfrow=c(1,1)) 
        
    })
    
    #---------------------------------------------------------------------------
    # Show the summary for the 
    output$reg.summary <- renderPrint({
        
        summary <- fit.regression()$fit.summary
        
        if (!is.null(summary)) {
            
            return(fit.regression()$fit.summary)
        }
        
    })
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # the data to print
    output$summary2 <- renderPrint({
        
        return(make.regression()$dd)
        
    })
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # the data to print
    output$summary3 <- renderPrint({
        
        return(make.regression()$ddd)
        
    })
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # the data to print, I wooulf like to reuse this but dont think it is possible? So I add another function to collect the same information below
    output$byhand <- renderPrint({
        
        return(explain()$ANOVA)
        
    })
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    output$byhand2 <- renderPrint({
        
        return(explain()$ANOVA2)
        
    })
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  
    
    
    output$p1 <- renderPrint({
        
        return(make.power()$power.func)
        
    })
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  
    output$p2 <- renderPrint({
        
        return(make.power()$power.sim)
        
    })
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  
    
})

# Run the application 
shinyApp(ui = ui, server = server)