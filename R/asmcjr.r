gray.palette <- function(n, lower=.3, upper=.7){
    s <- seq(lower, upper, length=n)
    rgb(matrix(rep(s, each=3), ncol=3, byrow=T))
}
ggplot.resphist <- function(result, groupVar=NULL, addStim = FALSE, scaleDensity=TRUE,
                    weights=c("all", "positive", "negative"), xlab=NULL,
                    main = NULL, ylab=NULL, whichRes=NULL, dim=NULL, ...){
    w <- match.arg(weights)
    shapes <- c(15,16,18, 24, 25, 0,1,2,3,4,5,6,7)
    if(class(result) == "aldmck"){
        v <- result$respondents
    }
    if(class(result) == "blackbox"){
        if(is.null(dim)){stop("For blackbox, 'dim' must be specified\n")}
        if(is.null(whichRes)){wres <- dim}
        v <- data.frame("idealpt" = result$individuals[[wres]][,dim], "weight" = 1)
    }
    if(!is.null(groupVar)){
        v$stimulus <- groupVar
    }
    v <- na.omit(v)
    xl <- ifelse(is.null(xlab), "Ideal Points", xlab)
    yl <- ifelse(is.null(ylab), "Density", ylab)
    main <- ifelse(is.null(main), "", main)
    if(is.null(groupVar)){
        if(w == "all"){
        g <- ggplot(v, aes(x=idealpt)) +  xlab(xl) + ylab(yl) + ggtitle(main) +stat_density(geom="line") + theme_bw()
        }
        if(w == "positive"){
            posv <- v[which(v$weight > 0),]
            xl <- paste0(xl, " (n=", nrow(posv), ")")
            g <- ggplot(posv, aes(x=idealpt)) +  xlab(xl) + ylab(yl) + ggtitle(main) + stat_density(geom="line")  + theme_bw()
        }
        if(w == "negative"){
            negv <- v[which(v$weight < 0),]
            xl <- paste0(xl, " (n=", nrow(negv), ")")
            g <- ggplot(negv, aes(x=idealpt)) +  xlab(xl) + ylab(yl) + ggtitle(main)+ stat_density(geom="line")  + theme_bw()
        }
    }
    else{
        ng <- length(table(v$stimulus))
        if(w == "all"){
            props <- table(v$stimulus)/sum(table(v$stimulus))
            bd <- by(v$idealpt, list(v$stimulus), density)
            lens <- sapply(bd, function(z)length(z$x))
            w0 <- which(lens == 0)
            if(length(w0) > 0){
                for(j in length(w0):1){bd[[w0[j]]] <- NULL}
            }
            for(i in 1:length(bd)){
                if(scaleDensity)bd[[i]]$y <- bd[[i]]$y*props[i]
                bd[[i]]$stimulus <- factor(i, levels=1:length(bd), labels=names(bd))
            }
            bd <- lapply(bd, function(z)data.frame("idealpt" = z$x, "Density"=z$y, "stimulus"=z$stimulus))
            bd <- do.call(rbind, bd)
            g <- ggplot(bd, aes(x=idealpt, y=Density, group=stimulus, color=stimulus)) + geom_line() + scale_color_manual(values=gray.palette(ng)) +
                 xlab(xl) + ylab(yl) + ggtitle(main) + theme_bw()
        }
        if(w == "positive"){
            posv <- v[which(v$weight > 0),]
            xl <- paste0(xl, " (n=", nrow(posv), ")")
            props <- table(posv$stimulus)/sum(table(posv$stimulus))
            bd <- by(posv$idealpt, list(posv$stimulus), density)
            lens <- sapply(bd, function(z)length(z$x))
            w0 <- which(lens == 0)
            if(length(w0) > 0){
                for(j in length(w0):1){bd[[w0[j]]] <- NULL}
            }
            for(i in 1:length(bd)){
                if(scaleDensity)bd[[i]]$y <- bd[[i]]$y*props[i]
                bd[[i]]$stimulus <- factor(i, levels=1:length(bd), labels=names(bd))
                }
            bd <- lapply(bd, function(z)data.frame("idealpt" = z$x, "Density"=z$y, "stimulus"=z$stimulus))
            bd <- do.call(rbind, bd)
            g <- ggplot(bd, aes(x=idealpt, y=Density, group=stimulus, color=stimulus)) + geom_line() + scale_color_manual(values=gray.palette(ng)) +
                 xlab(xl) + ylab(yl) + ggtitle(main) + theme_bw()
        }
        if(w == "negative"){
            negv <- v[which(v$weight < 0),]
            xl <- paste0(xl, " (n=", nrow(negv), ")")
            props <- table(negv$stimulus)/sum(table(negv$stimulus))
            bd <- by(negv$idealpt, list(negv$stimulus), density)
            lens <- sapply(bd, function(z)length(z$x))
            w0 <- which(lens == 0)
            if(length(w0) > 0){
                for(j in length(w0):1){bd[[w0[j]]] <- NULL}
            }
            for(i in 1:length(bd)){
                if(sacleDensity)bd[[i]]$y <- bd[[i]]$y*props[i]
                bd[[i]]$stimulus <- factor(i, levels=1:length(bd), labels=names(bd))
            }
            bd <- lapply(bd, function(z)data.frame("idealpt" = z$x, "Density"=z$y, "stimulus"=z$stimulus))
            bd <- do.call(rbind, bd)
            g <- ggplot(bd, aes(x=idealpt, y=Density, group=stimulus, color=stimulus)) + geom_line() + scale_color_manual(values=gray.palette(ng)) +
                 xlab(xl) + ylab(yl) + ggtitle(main) + theme_bw()
        }
    }
    if(addStim){
    tmp <- na.omit(result$stimuli)
    if(!is.null(groupVar)){
        tmp <- tmp[which(names(tmp) %in% unique(groupVar))]
        n <- names(tmp)
        p <- data.frame("idealpt" = tmp, "stimulus" = factor(n, levels=n[order(tmp)]))
        g <- g + geom_point(data=p, aes(y=0, group=stimulus, pch=stimulus, col=stimulus, size=2.5)) +
            scale_shape_manual(values=shapes[1:nrow(p)]) + theme_bw() + scale_size(2.5, guide=FALSE)
    }
    else{
        n <- names(tmp)
        p <- data.frame("idealpt" = tmp, "stimulus" = factor(n, levels=n[order(tmp)]))
        g <- g + geom_point(data=p, aes(y=0, group=stimulus, pch=stimulus, col=stimulus, size=2.5)) +
            scale_shape_manual(values=shapes[1:nrow(p)]) + scale_color_manual(values=gray.palette(nrow(p))) +
            theme_bw() + scale_size(2.5, guide=FALSE)
    }
    }
    return(g)
}

boot.aldmck <- function(data, ..., boot.args=list(), plot=FALSE){
    dot.args <- as.list(match.call(expand.dots = FALSE)$`...`)
    boot.fun <- function(data, inds, dot.args, ...){
        tmp <- data[inds, ]
        dot.args$data <- tmp
        out <- do.call("aldmck", dot.args)
        out$stimuli
    }
    boot.args$data <- data
    boot.args$statistic=boot.fun
    boot.args$dot.args=dot.args
    b <- do.call("boot", boot.args)
    out <- data.frame(
            "stimulus"= factor(names(b$t0), levels=names(b$t0)[order(b$t0)]),
            "idealpt" = b$t0,
            "sd" = apply(b$t, 2, sd))
    rownames(out) <- NULL
    out$lower <- out$idealpt - 1.96*out$sd
    out$upper <- out$idealpt + 1.96*out$sd
    out <- out[order(out$idealpt), ]
    class(out) <- c("aldmck_ci", "data.frame")
    return(list(sumstats=out, bootres=b))
}

boot.blackbox <- function(data, missing, dims=1, minscale, verbose=FALSE, posStimulus = 1, R=100){
        dot.args <- as.list(match.call(expand.dots = FALSE)$`...`)
        orig <- blackbox(data, missing=missing, dims=dims, minscale=minscale, verbose=verbose)
        if(orig$individuals[[dims]][posStimulus, 1] < 0){
            orig$individuals[[dims]][,1] <- -orig$individuals[[dims]][,1]
        }
        if(is.null(whichRes)){whichRes <- dim}
        sample.dat <- lapply(1:R, function(i)data[,sample(1:ncol(data), ncol(data), replace=TRUE)])
        for(i in 1:length(sample.dat))colnames(sample.dat[[i]]) <- 1:ncol(sample.dat[[i]])
        out <- array(dim=c(nrow(data), dims, R))
        for(i in 1:R){
            tmp <- blackbox(sample.dat[[i]], missing=missing, dims=dims, minscale=minscale, verbose=verbose)
            if(tmp$individuals[[dims]][posStimulus, 1] < 0){
                tmp$individuals[[dims]][,1] <- -tmp$individuals[[dims]][,1]
            }
            out[,,i] <- as.matrix(tmp$individuals[[dims]])
        }
        class(out) <- "bootbb"
        invisible(out)
    }
boot.blackbox_transpose <- function(data, missing, dims=1, minscale, verbose=FALSE, posStimulus = 1, R=100){
    out <- array(dim=c(ncol(data), dims, R))
    for(i in 1:R){
        tmp <- rankings[sample(1:nrow(rankings),
                                            nrow(rankings), replace=TRUE),]
        result <- blackbox_transpose(tmp,missing=missing,
                    dims=dims, minscale=minscale, verbose=verbose)
        if(result$stimuli[[dims]][posStimulus,2] > 0)
            result$stimuli[[dims]][,2] <- -1 *
            result$stimuli[[dims]][,2]
    out[,,i] <- as.matrix(result$stimuli[[dims]][,2:((2+dims)-1)])
    }
return(out)
}

plot.aldmck_ci <- function(x, ...){
    g <- ggplot(x, aes(x=idealpt, y=stimulus)) + geom_point() + geom_errorbarh(aes(xmin = lower, xmax=upper), height=0) + theme_bw()
    return(g)
}

bamPrep <- function(x, nmin=1, missing=NULL, self=1, midpt=NULL){
    x <- as.matrix(x)
    if(!is.numeric(x[,1])){stop("x must be a numeric data frame or matrix")}
    x[which(x %in% missing, arr.ind=T)] <- NA
    if(is.null(midpt)){
        x <- apply(x, 2, function(z)z-(min(z, na.rm=TRUE) + diff(range(z, na.rm=TRUE))/2))
    }
    else{
        x <- apply(x, 2, function(z)z-midpt)
    }
    nonmiss <- apply(x, 1, function(z)sum(!is.na(z)))
    x <- x[which(nonmiss >= nmin), ]
    out <- list(stims = x[,-self], self= x[,self])
    class(out) <- c("bamPrep", "list")
    out
}
print.aldmck_ci <- function(x, ..., digits=3){
    x$idealpt <- sprintf(paste0("%.", digits, "f"), x$idealpt)
    x$sd <- sprintf(paste0("%.", digits, "f"), x$sd)
    x$lower <- sprintf(paste0("%.", digits, "f"), x$lower)
    x$upper <- sprintf(paste0("%.", digits, "f"), x$upper)
    print.data.frame(x)
}

BAM <- function(data, polarity, zhatSave=TRUE, abSave=FALSE, resp.idealpts=FALSE, n.sample = 2500, ...){
if(!("bamPrep" %in% class(data)))stop("Data should be output from the bamPrep function")
args <- as.list(match.call(expand.dots = FALSE)$`...`)
if(!("n.chains" %in% names(args)))args$n.chains = 2
if(!("n.adapt" %in% names(args)))args$n.adapt = 10000
if(!("inits" %in% names(args))){
    orig <- aldmck(na.omit(data$stims), respondent=0, polarity=polarity, verbose=FALSE)
    args$inits <- function(){list(zhatstar = orig$stimuli + rnorm(length(orig$stimuli), 0, 1))}
}

args$file <- system.file("templates/BAM_JAGScode.bug", package="asmcjr")
args$data <- list('z'=data$stims, q = ncol(data$stims), N=nrow(data$stims))
mod.sim <- do.call("jags.model", args)

if(zhatSave & !abSave){
    samples <- coda.samples(mod.sim,'zhat',  n.sample,  thin=1)
    zhat <- samples
    for(i in 1:length(zhat)){colnames(zhat[[i]]) <- colnames(data$stims)}
    zhat.sum <- summary(zhat)
    zhat.ci <- data.frame("stimulus" = factor(colnames(data$stims), levels=colnames(data$stims)[order(zhat.sum$statistics)]),
                          "idealpt" = zhat.sum$statistics[,1],
                          "sd" = zhat.sum$statistics[,2],
                          "lower" = zhat.sum$quantiles[,1],
                          "upper" = zhat.sum$quantiles[,5])
    rownames(zhat.ci) <- NULL
    class(zhat.ci) <- c("aldmck_ci", "data.frame")
    res.list = list(zhat=zhat, zhat.ci = zhat.ci)
    }
if(abSave & !zhatSave){
    samples <- coda.samples(mod.sim, c('a', 'b'),  n.sample,  thin=1)
    a <- samples[,grep("^a", colnames(samples[[1]]))]
    b <- samples[,grep("&b", colnames(samples[[1]]))]
    res.list = list(a=a, b=b)
}
if(abSave & zhatSave){
    samples <- coda.samples(mod.sim, c('zhat', 'a', 'b'),  n.sample,  thin=1)
    zhat <- samples[,grep("^z", colnames(samples[[1]]))]
    for(i in 1:length(zhat)){colnames(zhat[[i]]) <- colnames(data$stims)}
    zhat.sum <- summary(zhat)
    zhat.ci <- data.frame("stimulus" = factor(colnames(data$stims), levels=colnames(data$stims)[order(zhat.sum$statistics)]),
                          "idealpt" = zhat.sum$statistics[,1],
                          "sd"= zhat.sum$statistics[,2],
                          "lower" = zhat.sum$quantiles[,1],
                          "upper" = zhat.sum$quantiles[,5])
    rownames(zhat.ci) <- NULL
    class(zhat.ci) <- c("aldmck_ci", "data.frame")
    a <- samples[,grep("^a", colnames(samples[[1]]))]
    b <- samples[,grep("^b", colnames(samples[[1]]))]
    res.list  = list(zhat=zhat, zhat.ci = zhat.ci, a=a, b=b)
}
if(resp.idealpts){
    amat <- do.call(rbind, res.list$a)
    bmat <- do.call(rbind, res.list$b)
    diffs <- t(apply(amat, 1, function(x)data$self-x))
    resp.ideals <- diffs /bmat
    resp.ideal.summary <-  t(apply(resp.ideals, 2, quantile, c(.025, .5, .975), na.rm=T))
    resp.ideal.summary <- as.data.frame(resp.ideal.summary)
    names(resp.ideal.summary) <- c("lower", "median", "upper")
    res.list$resp.samples=resp.ideals
    res.list$resp.summary = resp.ideal.summary
}
invisible(res.list)
}

diffStims <- function(x, stims, digits=3, ...){
    if("mcmc.list" %in% class(x)){
        x <- do.call("rbind", x)
    }
    if(!(is.matrix(x) | is.data.frame(x)))stop("x must be a matrix or data frame of MCMC or resampled values\n")
    x <- as.matrix(x)
    if(!is.numeric(stims)){
        stims <- match(stims, colnames(x))
    }
    combs <- combn(stims, 2)[,,drop=FALSE]
    D <- matrix(0, ncol=ncol(combs), nrow=ncol(x))
    D[cbind(combs[1,], 1:ncol(combs))] <- -1
    D[cbind(combs[2,], 1:ncol(combs))] <- 1
    diffs <- x %*%D
    probs <- colMeans(diffs > 0)
    comps <- paste("Pr(", colnames(x)[combs[2, ]], " > ", colnames(x)[combs[1,]], ")", sep="")
    result <- data.frame('Comparison'=comps, 'Probability'=sprintf(paste0("%.", digits, "f"), probs))
    result
}

aldmckSE <- function(obj, data, ...){
    tmp <- na.omit(cbind(obj$respondents[,1:2], data))
    alpha <- tmp[,1]
    beta <- tmp[,2]
    z <- tmp[,3:ncol(tmp)]
    zhat <- obj$stimuli
    sigmaj <- rep(0,length(zhat))
    #generate sigma j
    for (j in 1:length(zhat)){
        for (i in 1:length(alpha)){
            sigmaj[j] <- sigmaj[j]+((alpha[i] + beta[i]*zhat[j]) - z[i,j])^2
        }}
    for (i in 1:length(zhat)){
        sigmaj[i] <- sqrt((sigmaj[i]/length(alpha)))
    }
    sigmaj
}

ggplot.blackbox <- function(result, dims, whichRes=NULL, groupVar=NULL, issueVector=NULL,
    data=NULL, missing=NULL, rug=FALSE, xlab=NULL, main = NULL, ylab=NULL, nudgeX=NULL, nudgeY=NULL,...){
    wres <- ifelse(is.null(whichRes), max(dims), whichRes)
    dimdat <- result$individuals[[wres]][,dims]
    names(dimdat) <- c("x", "y")
    if(is.null(groupVar)){
        g <- ggplot(dimdat, aes(x=x, y=y)) + geom_point(shape=1, col="gray65") + theme_bw()
    }
    else{
        dimdat$group = groupVar
        dimdat$pch = substr(as.character(dimdat$group), 1, 1)
        ng <- length(unique(na.omit(groupVar)))
        g <- ggplot(dimdat, aes(x=x, y=y, group=group, col=group)) +
            scale_color_manual(values=gray.palette(ng)) +
            geom_point(alpha=0) +
            geom_text(aes(label=pch), show.legend=FALSE) +
            guides(colour = guide_legend("Grouping", override.aes = list(size = 2, alpha = 1))) +
            theme_bw()
    }
    if(rug){
        g <- g+geom_rug(show.legend=FALSE)
    }
    if(is.null(xlab)){
        ylab <- paste0("Dimension ", dims[1])
    }
    if(is.null(ylab)){
        ylab <- paste0("Dimension ", dims[2])
    }
    g <- g+ylab(ylab) + xlab(xlab)
    if(!is.null(issueVector)){
        if(is.null(data))stop("If you want to plot issue vectors, you need to specify the data\n")
        if(is.character(issueVector)){
            iss <- match(issueVector, colnames(data))
            if(length(iss) != length(issueVector))stop("At least one of the specified issues didn't match names in the data\n")
        }
        else{
            iss <- issueVector
        }
        dv <- data[,iss, drop=FALSE]
        dv[which(dv %in% missing, arr.ind=TRUE)] <- NA
        dv <- do.call("data.frame", lapply(1:ncol(dv), function(x)as.factor(dv[,x])))
        names(dv) <- colnames(data)[iss]
        op <- list()
        for(i in 1:ncol(dv)){
            op[[i]] <- polr(dv[,i] ~ x + y, data=dimdat, method="probit")
        }
        b <- sapply(op, function(x)x$coef)
        Nvals <- apply(b, 2, function(x)x/sqrt(sum(x^2)))
        scale.fac <- min(apply(dimdat[,1:2], 2, function(x)diff(range(x, na.rm=TRUE)))/2)
        for(i in 1:ncol(Nvals)){
            tmp <- data.frame(x=c(0, scale.fac*Nvals[1,i]), y=c(0, scale.fac*Nvals[2,i]))
            g <- g + geom_line(data=tmp, arrow = arrow(length=unit(0.30,"cm"), ends="first", type = "closed"), size=1.1) +
                geom_line(data=-tmp, arrow = arrow(length=unit(0.30,"cm"), ends="last", type = "closed"), size=1.1)
            }
        if(is.null(nudgeX)){nudgeX <- rep(0, ncol(Nvals))}
        if(is.null(nudgeY)){nudgeY <- rep(0, ncol(Nvals))}
        colnames(Nvals) <- colnames(data)[iss]
        nvals <- t(-Nvals*scale.fac)
        nvals <- as.data.frame(nvals)
        g <- g + geom_text(data=nvals, aes(x=x, y=y, label=rownames(nvals), size=2),
             nudge_x = nudgeX, nudge_y=nudgeY)
        }
    return(g)
}


