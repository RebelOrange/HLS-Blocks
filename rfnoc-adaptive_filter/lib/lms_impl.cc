/* -*- c++ -*- */
/* 
 * Copyright 2024 <+YOU OR YOUR COMPANY+>.
 * 
 * This is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3, or (at your option)
 * any later version.
 * 
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street,
 * Boston, MA 02110-1301, USA.
 */

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <gnuradio/io_signature.h>
#include "lms_impl.h"
namespace gr {
  namespace adaptive_filter {
    lms::sptr
    lms::make(
        const gr::ettus::rfnoc_graph::sptr graph,
        const ::uhd::device_addr_t& block_args,
        const int device_select,
        const int instance
    )
    {
      return gnuradio::get_initial_sptr(
        new lms_impl(
          gr::ettus::rfnoc_block::make_block_ref(
            graph, block_args, "lms", device_select, instance)));
    }

    /*
     * The private constructor
     */
    lms_impl::lms_impl(
        ::uhd::rfnoc::noc_block_base::sptr block_ref) :
      gr::ettus::rfnoc_block(block_ref),
      d_lms_ref(get_block_ref<::uhd::rfnoc::lms_block_ctrl>())
    {
    }

    /*
     * Our virtual destructor.
     */
    lms_impl::~lms_impl()
    {
    }

  } /* namespace adaptive_filter */
} /* namespace gr */

