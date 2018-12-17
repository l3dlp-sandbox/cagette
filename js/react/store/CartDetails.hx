package react.store;

import classnames.ClassNames.fastNull as classNames;
import react.ReactComponent;
import react.ReactMacro.jsx;
import mui.CagetteTheme.CGColors;
import mui.core.Card;
import mui.core.CardMedia;
import mui.core.CardContent;
import mui.core.Grid;

import mui.core.Typography;
import mui.icon.Icon;
import mui.core.Button;
import mui.core.IconButton;
import mui.IconColor;

import mui.core.styles.Classes;
import mui.core.styles.Styles;

import react.cagette.action.CartAction;
import Formatting.unit;
import Common;
using Lambda;


typedef CartDetailsProps = {
	> PublicProps,
	> ReduxProps,
	var classes:TClasses;
}

private typedef ReduxProps = {
	var updateCart:ProductInfo->Int->Void;
	var removeProduct:ProductInfo->Void;
	var resetCart:Void->Void;
	var order:OrderSimple;
}

private typedef PublicProps = {
	var submitOrder:OrderSimple->Void;
}

private typedef TClasses = Classes<[
	gridItem,

	cartDetails, 
	cartFooter,
	products, 
	product, 
	iconStyle, 
	card, 
	cover,

	cagProductTitle,
    cagProductInfoWrap,
    cagProductInfo,
    cagProductPriceRate,
	
	]>

@:publicProps(PublicProps)
@:connect
@:wrap(untyped Styles.withStyles(styles))
class CartDetails extends react.ReactComponentOfProps<CartDetailsProps> {
	
	public static function styles(theme:mui.CagetteTheme):ClassesDef<TClasses> {
		return {
			gridItem: {
				overflow: Hidden,
			},
			cartFooter: {
				display: "flex",
				flexDirection: Column,
			},
			cartDetails : {
                fontSize: "1.2rem",
                fontWeight: "bold",//TODO use enum from externs when available
                display: "flex",
				flexDirection: Column,
                width: 400,
            },
			products : {
				display: "flex",
				justifyContent: SpaceAround,
				alignItems: Center,
			},
			product : {
				height: 80,
				padding: 8,
				marginBottom: 6,
				overflow: Hidden,
				alignItems:Center,
				justifyContent:SpaceEvenly,
			},
			iconStyle:{
				fontSize:12,
			},
			card: {
				display: 'flex',
				flexDirection: Row,
			},
			
			cover: {
				width: '70px',
				height: '70px',
				objectFit: "cover",
			},
			
			cagProductTitle: {
                fontSize: '0.8rem',
                fontStyle: "normal",
                textTransform: UpperCase,
                marginBottom: 3,

				overflow: Hidden,
				//whiteSpace: NoWrap,
				textOverflow: Ellipsis,

				lineHeight: "1.0em",
  				maxHeight: "1.8em",

				alignSelf: "flex-start",

            },
            cagProductInfoWrap : {       
                justifyContent: SpaceBetween,
                padding: "0 5px",
            },
            cagProductInfo : {
                fontSize : "1.0rem",
                "& .cagProductUnit" : {
                    marginRight: "2rem",
                },

                "& .cagProductPrice" : {
                    color : CGColors.Third,        
                },
            },
            cagProductPriceRate : {        
                fontSize: "0.5rem",
                color : CGColors.Secondfont,
                marginTop : -3,
                marginLeft: 3,
            },
		}
	}

	static function mapStateToProps(st:react.cagette.state.State):react.Partial<CartDetailsProps> {
		return {
			order: cast st.cart,
		}
	}

	static function mapDispatchToProps(dispatch:redux.Redux.Dispatch):react.Partial<CartDetailsProps> {
		return {
			updateCart: function(product, quantity) {
				dispatch(CartAction.UpdateQuantity(product, quantity));
			},
			resetCart: function() {
				dispatch(CartAction.ResetCart);
			},
			removeProduct: function(p:ProductInfo) {
				dispatch(CartAction.RemoveProduct(p));
			}
		}
	}

	override public function render() {
		var classes = props.classes;
		return jsx('
			<div className=${classes.cartDetails}>
				<h3>Ma Commande</h3>
				${renderProducts()}
				${renderFooter()}
			</div>
        ');
    }


	function updateQuantity(cartProduct:ProductWithQuantity, newValue:Int) {
		props.updateCart(cartProduct.product, newValue);
	}

	function renderProducts() {

		if( props.order.products == null || props.order.products.length == 0 ) return null;

		var classes = props.classes;
		var cl = classNames({
			'icons':true,
			'icon-delete':true,
		});

        var productsToOrder = props.order.products.map(function(cartProduct:ProductWithQuantity) {
			var quantity = cartProduct.quantity;
			var product = cartProduct.product;
			 var productType = unit(product.unitType);

			return jsx('
				<Grid className=${classes.product} container={true} direction=${Row} spacing={4} key=${product.id}>
					<Grid item xs={2} className=${classes.gridItem}>
						<Card className=${classes.card} elevation={0}>
							<CardMedia
								className=${classes.cover}
								image=${product.image}
							/>
						</Card>
					</Grid>
					<Grid item={true} xs={3} className=${classes.gridItem}>
						<Typography component="h3" className=${classes.cagProductTitle}>
                            ${product.name}
                        </Typography>
						 <Typography component="p" className=${classes.cagProductPriceRate} >
							${product.price} €/${(productType)}
						</Typography> 
					</Grid>
					<Grid item={true} xs={2} className=${classes.gridItem}>
						<Typography component="p" className=${classes.cagProductInfo} >
							<span className="cagProductUnit">1${(productType)}</span>	
						</Typography>
						<Typography component="p" className=${classes.cagProductInfo} >
							<span className="cagProductPrice">${product.price} €</span>
						</Typography>
					</Grid>
					<Grid item={true} xs={3}>
						<QuantityInput onChange=${updateQuantity.bind(cartProduct)} value=${quantity} />
					</Grid>
					<Grid item={true} xs={1}>
						<IconButton onClick=${props.removeProduct.bind(product)} style={{padding:4}}>
							<Icon component="i" className=${cl} color=${Primary}></Icon>
						</IconButton>
					</Grid>
				</Grid>
			');
		});

		return jsx('
			<Grid className=${classes.products} container={true} direction=${Column} spacing={8}>
				${productsToOrder}
			</Grid>
		');
	}

    function renderFooter() {
		var classes = props.classes;
		var submit = props.submitOrder.bind(props.order);
		var disabled= false;
		if (props.order.products.length == 0) {
			submit = null;
			disabled = true;
		}

		return jsx('
			<Grid className=${classes.cartFooter} container={true} direction=${Column} key="footer">
				<Grid item={true} xs={12}>
					<Typography component="h2">Total</Typography>
					<Typography component="p">${props.order.total} €</Typography>
				</Grid>
				<Grid item={true} xs={12}>
					<Button
                        onClick=${submit}
                        variant=${Contained}
                        color=${Primary} 
						disabled=${disabled}
                        >                        
                        COMMANDER
                    </Button>
				</Grid>
			</Grid>
		');
	}
}

