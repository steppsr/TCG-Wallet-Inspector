#!/bin/bash
#
# Chia TCG - Wallet Inspector
#
echo""
echo "████████╗ ██████╗ ██████╗     ██╗    ██╗ █████╗ ██╗     ██╗     ███████╗████████╗    ██╗███╗   ██╗███████╗██████╗ ███████╗ ██████╗████████╗ ██████╗ ██████╗ "
echo "╚══██╔══╝██╔════╝██╔════╝     ██║    ██║██╔══██╗██║     ██║     ██╔════╝╚══██╔══╝    ██║████╗  ██║██╔════╝██╔══██╗██╔════╝██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗"
echo "   ██║   ██║     ██║  ███╗    ██║ █╗ ██║███████║██║     ██║     █████╗     ██║       ██║██╔██╗ ██║███████╗██████╔╝█████╗  ██║        ██║   ██║   ██║██████╔╝"
echo "   ██║   ██║     ██║   ██║    ██║███╗██║██╔══██║██║     ██║     ██╔══╝     ██║       ██║██║╚██╗██║╚════██║██╔═══╝ ██╔══╝  ██║        ██║   ██║   ██║██╔══██╗"
echo "   ██║   ╚██████╗╚██████╔╝    ╚███╔███╔╝██║  ██║███████╗███████╗███████╗   ██║       ██║██║ ╚████║███████║██║     ███████╗╚██████╗   ██║   ╚██████╔╝██║  ██║"
echo "   ╚═╝    ╚═════╝ ╚═════╝      ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝   ╚═╝       ╚═╝╚═╝  ╚═══╝╚══════╝╚═╝     ╚══════╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝"
echo "                                                                                                                  powered by the MintGarden API. Version 0.1"
echo "____________________________________________________________________________________________________________________________________________________________"
echo ""
wallet_list=`chia wallet show -w nft | grep "Wallet ID" | cut -c 28- | tr '\n' ' '`
echo -e " NFT Wallet IDs: ${txtrst}$wallet_list${bldgrn}"
echo ""
read -p " Wallet ID, or [Enter] for all, or [x] to cancel? " answer_wallet

if [ "$answer_wallet" != "X" ] && [ "$answer_wallet" != "x" ]; then

	if [ "$answer_wallet" != "" ]; then
		wallet_list="$answer_wallet"
	fi

	all=0
	for val in $wallet_list; do
		echo ""
		echo " ==== Wallet ID: $val ===="
		echo "Wallet $val" > wallet_$val.ids

		c=`chia rpc wallet nft_count_nfts '{"wallet_id":'$val'}' | jq -r '.count'`
		nft_ids=`chia rpc wallet nft_get_nfts '{"wallet_id":'$val', "start_index":0, "num":'$c', "ignore_size_limit": false}' | grep "nft_id" | cut -c 24-85`

		nft_collection=""
		nft_name=""

		for id in $nft_ids; do

			nft_json=`curl -s https://api.mintgarden.io/nfts/$id`
			nft_collection=`echo "$nft_json" | jq '.collection.name' | cut --fields 2 --delimiter=\"`
			nft_collection_id=`echo "$nft_json" | jq '.collection.id' | cut --fields 2 --delimiter=\"`
			nft_name=`echo "$nft_json" | jq '.data.metadata_json.name' | cut --fields 2 --delimiter=\"`

			tcg_tier=`echo "$nft_json" | jq '.chiatcg_stats.tier' | cut --fields 2 --delimiter=\"`
			tcg_cpu=`echo "$nft_json" | jq '.chiatcg_stats.cpu' | cut --fields 2 --delimiter=\"`
			tcg_mem=`echo "$nft_json" | jq '.chiatcg_stats.mem' | cut --fields 2 --delimiter=\"`
			tcg_faction=`echo "$nft_json" | jq '.chiatcg_stats.faction' | cut --fields 2 --delimiter=\"`
			tcg_core_script=`echo "$nft_json" | jq '.chiatcg_stats.core_script' | cut --fields 2 --delimiter=\"`

			echo -e "${txtrst}[T$tcg_tier] $id [$nft_collection] $nft_name -- ChiaTCG[T$tcg_tier, CPU:$tcg_cpu, MEM:$tcg_mem, Faction:$tcg_faction, Script:$tcg_core_script] ${bldgrn}"
		done

		echo -e " Wallet Count Total: ${txtrst}$c${bldgrn}"
		all=$(($all+$c))
	done

	echo ""
	echo -e " Total number of NFTs: ${txtrst}$all${bldgrn}"
fi
